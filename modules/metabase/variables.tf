# variable "cloudflare_api_token" {
#   description = "(Required) The Cloudflare API token."
#   type        = string
# }

variable "ecs_aws_ecs_cluster_id" {
  description = "(Required) ECS Cluster id"
}

variable "ecs_aws_security_group_id" {
  description = "(Required) ECS Security Group id"
}

variable "ecs_aws_cloudwatch_log_group_name" {
  description = "(Required) ECS CloudWatch Logs Group name"
}

variable "ecs_aws_lb_listener_https_arn" {
  description = "(Required) ECS Load Balancer Https Listener Arn"
}
variable "ecs_aws_iam_role_arn" {
  description = "(Required) ECS IAM Role Arn"
}


variable "tourly_environment" {
  description = "(Required) Tourly Environment this should be connecting to"
}

variable "private_subnet_ids" {
  description = "(Required) IDs of the subnets to which the services and database will be deployed"
}

variable "domain" {
  description = "(Required) Domain where metabase will be hosted. Example: metabase.mycompany.com"
}

# variable "zone_id" {
#   description = "(Required) https://www.terraform.io/docs/providers/aws/r/route53_record.html#zone_id"
# }

variable "vpc_id" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/security_group.html#vpc_id"
}

variable "id" {
  description = "(Optional) Unique identifier for naming resources"
  default     = "metabase-test"
}

variable "tags" {
  description = "(Optional) Tags applied to all resources"
  default     = {Tool = "metabase", Environment = "test"}
}

variable "image" {
  description = "(Optional) https://hub.docker.com/r/metabase/metabase"
  default     = "metabase/metabase"
}

variable "cpu" {
  description = "(Optional) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = "512"
}

variable "memory" {
  description = "(Optional) https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html"
  default     = "2048" # must be in integer format to maintain idempotency
}

variable "max_capacity" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#max_capacity"
  default     = "2"
}

variable "desired_count" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/ecs_service.html#desired_count"
  default     = "1"
}

variable "log_retention" {
  description = "(Optional) Retention period in days for both ALB and container logs"
  default     = "30"
}

variable "protection" {
  description = "(Optional) Protect ALB and application logs from deletion"
  default     = false
}

variable "internet_egress" {
  description = "(Optional) Grant internet access to the Metabase service"
  default     = true
}

variable "ssl_policy" {
  description = "(Optional) https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-security-policy-table.html"
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "snapshot_identifier" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#snapshot_identifier"
  default     = ""
}

variable "environment" {
  description = "(Optional) Additional container environment variables"
  default     = []
}

variable "java_timezone" {
  description = "(Optional) https://www.metabase.com/docs/v0.21.1/operations-guide/running-metabase-on-docker.html#setting-the-java-timezone"
  default     = "Portugal"
}

variable "db_cluster_parameter_group_name" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#db_cluster_parameter_group_name"
  default     = ""
}

variable "auto_pause" {
  description = "(Optional) https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#auto_pause"
  default     = true
}
