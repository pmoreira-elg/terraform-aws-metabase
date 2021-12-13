variable "ecs_aws_ecs_cluster_id" {
  description = "(Required) ECS Cluster id"
}
variable "ecs_aws_ecs_cluster_arn" {
  description = "(Required) ECS Cluster arn"
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

variable "name" {
  type        = string
  description = "Base name for the cluster and other resources"
}

variable "stage" {
  type        = string
  description = "Stage of the deployment (Production/Development etc)"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to be attached for every resource in the module"
  default     = {}
}

variable "region" {
  type        = string
  description = "Region in which resources should be created"
}

variable "instance_type" {
  type        = string
  description = "Type of ECS container intance type"
}

variable "ebs_volume_type" {
  type        = string
  description = "Type of EBS volume to be used for container storage"
}

variable "ebs_volume_size" {
  type        = number
  description = "Size of ebs volume"
}

variable "mongo_container_cpu" {
  type        = number
  description = "CPU capacity required for mongo container ( 1024 == 1 cpu)"
}

variable "mongo_version" {
  type        = string
  description = "Docker image version of mongo"
}

variable "mongo_container_memory" {
  type        = number
  description = "Memory required for mongo container"
}

variable "security_group_id" {
  type        = string
  description = "Security group id for container EC2 instance"
}

variable "private_subnet_ids" {
  description = "(Required) IDs of the subnets to which the services and database will be deployed"
}

variable "vpc_id" {
  description = "(Required) https://www.terraform.io/docs/providers/aws/r/security_group.html#vpc_id"
}
variable "domain" {
  description = "(Required) Domain where metabase will be hosted. Example: metabase.mycompany.com"
}