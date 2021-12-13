resource "aws_rds_cluster" "this" {
  cluster_identifier              = "${var.id}"
  final_snapshot_identifier       = "${var.id}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  copy_tags_to_snapshot           = true
  engine                          = "aurora"
  engine_mode                     = "serverless"
  database_name                   = "metabase"
  master_username                 = "root"
  master_password                 = random_string.this.result
  backup_retention_period         = 5 # days
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = [aws_security_group.rds.id]
  db_subnet_group_name            = aws_db_subnet_group.this.id
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  deletion_protection             = var.protection
  enable_http_endpoint            = true
  tags                            = var.tags
  apply_immediately               = true

  scaling_configuration {
    auto_pause   = var.auto_pause
    min_capacity = 1
    max_capacity = var.max_capacity
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [snapshot_identifier, final_snapshot_identifier]
  }
}

resource "random_string" "this" {
  length  = 32
  special = false

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ssm_parameter" "this" {
  name        = var.id
  description = "RDS password"
  type        = "SecureString"
  value       = random_string.this.result
  tags        = var.tags
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "rds-db-credentials/${aws_rds_cluster.this.cluster_resource_id}/${var.id}"
  description             = "RDS credentials for use in query editor"
  recovery_window_in_days = 0
  tags                    = var.tags
}

locals {
  secret = {
    dbInstanceIdentifier = aws_rds_cluster.this.cluster_identifier
    engine               = aws_rds_cluster.this.engine
    dbname               = aws_rds_cluster.this.database_name
    host                 = aws_rds_cluster.this.endpoint
    port                 = aws_rds_cluster.this.port
    resourceId           = aws_rds_cluster.this.cluster_resource_id
    username             = aws_rds_cluster.this.master_username
    password             = random_string.this.result
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(local.secret)
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.id}-sbg"
  subnet_ids  = tolist(var.private_subnet_ids)
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds" {
  name    = "${var.id}-sg-rds"
  vpc_id  = var.vpc_id
  tags    = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rds_ingress_ecs" {
  description              = "ECS"
  type                     = "ingress"
  from_port                = aws_rds_cluster.this.port
  to_port                  = aws_rds_cluster.this.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.ecs_aws_security_group_id  #aws_security_group.ecs.id
}


# ECS Related
data "aws_region" "this" {}

locals {
  container = [
    {
      name        = "metabase"
      image       = var.image
      essential   = true
      environment = concat(local.environment, var.environment)

      secrets = [
        {
          name      = "MB_DB_PASS"
          valueFrom = aws_ssm_parameter.this.name
        },
      ]

      portMappings = [
        {
          containerPort = 3000
        },
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = var.ecs_aws_cloudwatch_log_group_name
          awslogs-region        = data.aws_region.this.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ]

  environment = [
    {
      name  = "JAVA_TIMEZONE"
      value = var.java_timezone
    },
    {
      name  = "MB_DB_TYPE"
      value = "mysql"
    },
    {
      name  = "MB_DB_DBNAME"
      value = aws_rds_cluster.this.database_name
    },
    {
      name  = "MB_DB_PORT"
      value = tostring(aws_rds_cluster.this.port)
    },
    {
      name  = "MB_DB_USER"
      value = aws_rds_cluster.this.master_username
    },
    {
      name  = "MB_DB_HOST"
      value = aws_rds_cluster.this.endpoint
    },
  ]
}

resource "aws_lb_listener_rule" "this" {
  listener_arn = var.ecs_aws_lb_listener_https_arn   #aws_lb_listener.https.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.id}-lbtg"
  port        = local.container[0].portMappings[0].containerPort
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path = "/"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.tourly_environment}-tools-task-definition"
  container_definitions    = jsonencode(local.container)
  execution_role_arn       = var.ecs_aws_iam_role_arn   #aws_iam_role.this.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  tags                     = var.tags
}

resource "aws_ecs_service" "this" {
  name                              = "${var.tourly_environment}-tools-service"
  cluster                           = var.ecs_aws_ecs_cluster_id #aws_ecs_cluster.this.id
  task_definition                   = aws_ecs_task_definition.this.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  propagate_tags                    = "SERVICE"
  health_check_grace_period_seconds = 30
  depends_on                        = [aws_lb_listener_rule.this]
  tags                              = var.tags

  load_balancer {
    target_group_arn = aws_lb_target_group.this.id
    container_name   = local.container[0].name
    container_port   = local.container[0].portMappings[0].containerPort
  }

  network_configuration {
    security_groups = [var.ecs_aws_security_group_id]  #[aws_security_group.ecs.id]
    subnets         = tolist(var.private_subnet_ids)
  }
}

resource "aws_security_group_rule" "ecs_egress_rds" {
  description              = "ALB"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = var.ecs_aws_security_group_id  #aws_security_group.ecs.id
  source_security_group_id = aws_security_group.rds.id
}