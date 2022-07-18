output "controller_dns" {
  value       = var.datastore_acm_certificate_arn != "" && var.controller_acm_certificate_arn == "" || var.internal_controller_alb ? "Not Created" : var.controller_acm_certificate_arn == "" ? "https://${aws_route53_record.controller[0].fqdn}" : "Please create CNAME record to endpoint with assosiated domain of certificate provided"
  description = "Rookout's on-prem controller dns"
}

output "controller_endpoint" {
  value       = aws_alb.controller[0].dns_name
  description = "Rookout's on-prem controller endpoint"
}

output "datastore_dns" {
  value       = var.deploy_datastore && var.domain_name != "" ? "https://${aws_route53_record.datastore[0].fqdn}" : var.datastore_acm_certificate_arn == "" ? "Not Created" : "Please create CNAME record to endpoint with assosiated domain of certificate provided"
  description = "Rookout's on-prem datastore DNS"
}

output "datastore_endpoint" {
  value       = var.deploy_datastore ? aws_alb.datastore[0].dns_name : "Not Created"
  description = "Rookout's on-prem datastore endpoint"
}

output "demo_dns" {
  value       = var.deploy_demo_app && var.domain_name != "" ? "https://${aws_route53_record.demo[0].fqdn}" : "Not Created"
  description = "Rookout's flask application DNS"
}

output "demo_endpoint" {
  value       = var.deploy_demo_app ? aws_alb.demo[0].dns_name : "Not Created"
  description = "Rookout's flask application endpoint"
}

output "vpc_id" {
  value       = var.create_vpc ? module.vpc[0].vpc_id : "Not created"
  description = "VPC id that created"
}

output "ecs_cluster_id" {
  value       = var.create_cluster ? aws_ecs_cluster.rookout[0].id : "Not created"
  description = "ECS cluster"
}