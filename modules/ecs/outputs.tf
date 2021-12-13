output "ecs_aws_ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_aws_ecs_cluster_arn" {
  value = aws_ecs_cluster.this.arn
}

output "ecs_aws_security_group_id" {
  value = aws_security_group.ecs.id  
}

output "ecs_aws_cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}

output "ecs_aws_lb_listener_https_arn" {
  value = aws_lb_listener.https.arn
}

output "ecs_aws_iam_role_arn" {
  value = aws_iam_role.this.arn
}