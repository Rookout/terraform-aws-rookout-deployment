locals {
  tags = {
    terraform   = true
    Environment = var.environment
  }
}
resource "aws_ecs_cluster" "rookout" {
  count = var.create_cluster ? 1 : 0
  name  = "Rookout-ecs-cluster"

  tags = local.tags
}

data "aws_ecs_cluster" "provided" {
  count        = var.create_cluster ? 0 : 1
  cluster_name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "rookout" {
  name_prefix = "rookout"
}

resource "aws_cloudwatch_log_group" "demo" {
  count       = var.deploy_demo ? 1 : 0
  name_prefix = "demo"
}
