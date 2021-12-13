module "ecs" {
  source             = "./modules/ecs"

  tourly_environment = var.tourly_environment
  public_subnet_ids  = ["${aws_subnet.a.id}","${aws_subnet.b.id}"]
  vpc_id             = aws_vpc.this.id
  certificate_arn    = "arn:aws:acm:eu-west-1:789374559236:certificate/51049b24-5184-4507-b7e5-3e811786710b"
}

# module "metabase" {
#   source                            = "./modules/metabase"
#   depends_on = [
#     module.ecs
#   ]

#   tourly_environment                = var.tourly_environment
#   private_subnet_ids                = ["${aws_subnet.a.id}","${aws_subnet.b.id}"]
#   vpc_id                            = aws_vpc.this.id
#   domain                            = "metabase-${var.tourly_environment}.tourly.pt"
#   ecs_aws_ecs_cluster_id            = module.ecs.ecs_aws_ecs_cluster_id
#   ecs_aws_iam_role_arn              = module.ecs.ecs_aws_iam_role_arn
#   ecs_aws_security_group_id         = module.ecs.ecs_aws_security_group_id
#   ecs_aws_cloudwatch_log_group_name = module.ecs.ecs_aws_cloudwatch_log_group_name
#   ecs_aws_lb_listener_https_arn     = module.ecs.ecs_aws_lb_listener_https_arn
# }

module "mongo" {
  source                            = "./modules/mongodb"
  depends_on = [
    module.ecs
  ]
  private_subnet_ids                = ["${aws_subnet.a.id}","${aws_subnet.b.id}"]
  security_group_id                 = module.ecs.ecs_aws_security_group_id
  ebs_volume_size                   = 5
  ebs_volume_type                   = "gp2"
  instance_type                     = "t4g.small"
  name                              = "test-mongo"
  region                            = "eu-west-1"
  stage                             = "Development"
  mongo_container_cpu               = 512
  mongo_container_memory            = 1024
  mongo_version                     = "latest" //Version tag of mongo docker image
  ecs_aws_ecs_cluster_id            = module.ecs.ecs_aws_ecs_cluster_id
  ecs_aws_ecs_cluster_arn           = module.ecs.ecs_aws_ecs_cluster_arn
  ecs_aws_iam_role_arn              = module.ecs.ecs_aws_iam_role_arn
  ecs_aws_security_group_id         = module.ecs.ecs_aws_security_group_id
  ecs_aws_cloudwatch_log_group_name = module.ecs.ecs_aws_cloudwatch_log_group_name
  ecs_aws_lb_listener_https_arn     = module.ecs.ecs_aws_lb_listener_https_arn
  vpc_id                            = aws_vpc.this.id
  domain                            = "mongodb-${var.tourly_environment}.tourly.pt"
  tourly_environment                = var.tourly_environment

  tags = {
    Environment = "Development"
    TF-Managed  = true
  }
}

locals {
  tags = {
    Environment = var.tourly_environment
    TF-Managed  = true
  }
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags       = local.tags
  enable_dns_hostnames =  true # required for mongodb to access EFS
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.this.id
  tags = local.tags
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

   tags = local.tags
}

resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, 0)
  availability_zone = "eu-west-1a"
  tags = local.tags
}

resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, 1)
  availability_zone = "eu-west-1b"
  tags = local.tags
}

provider "aws" {
  region = "eu-west-1"
  max_retries = 1
  profile     = "AdministratorAccess-789374559236"
}