data "aws_region" "this" {}

resource "aws_efs_file_system" "mongo_fs" {
  creation_token = var.name

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

resource "aws_ecs_task_definition" "mongo-task" {
  container_definitions    = jsonencode(local.container)
  family                   = var.name
  execution_role_arn       = var.ecs_aws_iam_role_arn   #aws_iam_role.this.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  volume {
    name = var.name

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.mongo_fs.id
      root_directory          = "/${var.name}-${var.tourly_environment}"
      transit_encryption      = "DISABLED"
    }
  }
  tags = var.tags
}

resource "aws_ecs_service" "mongodb-ecs-service" {
  name                               = var.name
  cluster                            = var.ecs_aws_ecs_cluster_arn
  task_definition                    = aws_ecs_task_definition.mongo-task.arn
  desired_count                      = 1
  launch_type                       = "FARGATE"
  propagate_tags                    = "SERVICE"
  health_check_grace_period_seconds = 30
  depends_on                        = [aws_lb_listener_rule.this]
  tags                              = var.tags

  load_balancer {
    target_group_arn = aws_lb_target_group.this.id
    container_name   = "mongodb"
    container_port   = "27017"
  }

  network_configuration {
    security_groups = [var.ecs_aws_security_group_id]  #[aws_security_group.ecs.id]
    subnets         = tolist(var.private_subnet_ids)
    assign_public_ip = true
  }
}

resource "aws_security_group_rule" "ecs_egress_mongo" {
  description              = "ALB"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = var.ecs_aws_security_group_id  #aws_security_group.ecs.id
  source_security_group_id = aws_security_group.mongo.id
}
resource "aws_security_group" "mongo" {
  name    = "${var.name}-sg-mongo"
  vpc_id  = var.vpc_id
  tags    = var.tags

  lifecycle {
    create_before_destroy = true
  }
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
  name        = "${var.name}-lbtg"
  port        = "27017"
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags        = var.tags

  health_check {
    path = "/"
  }
}

locals {
  container = [
    {
      name        = "mongodb"
      image       = "docker.io/mongo:${var.mongo_version}"
      essential   = true
      cpu         = "${var.mongo_container_cpu}"
      memory      = "${var.mongo_container_memory}"

      portMappings = [
        {
          containerPort = 27017,
          hostPort      = 27017
        },
      ]
      environment = [
        {
          name = "MONGO_INITDB_ROOT_USERNAME",
          value = "root"
        },
        {
          name = "MONGO_INITDB_ROOT_PASSWORD",
          value = "1R$g0!Qcih!x4%gm"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = var.ecs_aws_cloudwatch_log_group_name
          awslogs-region        = data.aws_region.this.name
          awslogs-stream-prefix = "mongodb"
        }
      }
      mountPoints = [
        {
          sourceVolume  = var.name
          containerPath = "/data/db"
        }
      ]
    }
  ]
}