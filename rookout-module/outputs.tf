output "controller_dns" {
  value       = "https://${aws_route53_record.controller.fqdn}"
  description = "Rookout's on-prem controller dns"
}

output "controller_endpoint" {
  value       = aws_alb.controller.dns_name
  description = "Rookout's on-prem controller endpoint"
}

output "datastore_dns" {
  value       = var.deploy_datastore ? "https://${aws_route53_record.datastore[0].fqdn}" : "Not Created"
  description = "Rookout's on-prem datastore DNS"
}

output "datastore_endpoint" {
  value       = var.deploy_datastore ? aws_alb.datastore[0].dns_name : "Not Created"
  description = "Rookout's on-prem datastore endpoint"
}

output "demo_dns" {
  value       = var.deploy_demo_app ? "https://${aws_route53_record.demo[0].fqdn}" : "Not Created"
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