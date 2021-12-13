output "rds_security_group_id" {
  description = "https://www.terraform.io/docs/providers/aws/r/security_group.html#id"
  value       = aws_security_group.rds.id
}

output "rds_port" {
  description = "https://www.terraform.io/docs/providers/aws/r/rds_cluster.html#port-1"
  value       = aws_rds_cluster.this.port
}

output "target_group_arn" {
  description = "https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#arn"
  value       = aws_lb_target_group.this.arn
}

# output "aws_acm_certificate" {
#   description = "https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate#domain_validation_options"
#   value = aws_acm_certificate.cert.arn
# }