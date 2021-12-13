output "listener_arn" {
  description = "https://www.terraform.io/docs/providers/aws/r/lb_listener.html#arn"
  value       = module.ecs.ecs_aws_lb_listener_https_arn
}

# output "target_group_arn" {
#   description = "https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#arn"
#   value       = module.metabase.target_group_arn
#   depends_on = [
#     metabase.target_group_arn,
#   ]
# }
# output "rds_security_group_id" {
#   description = "https://www.terraform.io/docs/providers/aws/r/security_group.html#id"
#   value       = module.metabase.rds_security_group_id
#   depends_on = [
#     metabase.rds_security_group_id,
#   ]
# }

# output "rds_port" {
#   description = "https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#port-1"
#   value       = module.metabase.rds_port
#   depends_on = [
#     metabase.rds_port,
#   ]
# }
