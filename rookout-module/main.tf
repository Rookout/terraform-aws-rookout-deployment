resource "aws_service_discovery_private_dns_namespace" "main" {
   name        = var.prviate_dns_namespace_name
   description = "Rookout local cloud map namespaces for ECS cluster."
   vpc         = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
}

resource "aws_ecs_cluster" "rookout" {
   count        = var.create_cluster ? 1 : 0
   name         = "Rookout-ecs-cluster"
}

data "aws_ecs_cluster" "provided" {
   count        = var.create_cluster ? 0 : 1
   cluster_name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "rookout" {
   name_prefix = "rookout"
}


data "aws_route53_zone" "this" {
  name         = var.prviate_dns_namespace_name
  private_zone = true
}

resource "aws_route53_resolver_endpoint" "rookout" {
  name      = "rookout"
  direction = "INBOUND"

  security_group_ids = [
    aws_security_group.aws_route53_resolver_endpoint.id,
  ]

  dynamic "ip_address"{
     for_each = module.vpc[0].private_subnets
     content{
        subnet_id = ip_address.value
     }
  }

  tags = {
    Environment = "rookout"
  }
}

 resource "aws_security_group" "aws_route53_resolver_endpoint" {

   name        = "aws_route53_resolver_endpoint"
   description = "Allow inbound/outbound traffic for client VPC"
   vpc_id      = module.vpc[0].vpc_id
   ingress {
     description = "Inbound from IGW to controller"
     from_port   = 53
     to_port     = 53
     protocol    = "udp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
     description      = "Outbound all"
     from_port        = 0
     to_port          = 0
     protocol         = "-1"
     cidr_blocks      = ["0.0.0.0/0"]
     ipv6_cidr_blocks = ["::/0"]
   }
 }