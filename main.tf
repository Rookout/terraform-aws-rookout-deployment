data "aws_region" "current" {}
locals {
  region = var.region == "" ? data.aws_region.current.name : var.region
  tags = {
    terraform   = true
    Environment = var.environment
    Service     = "rookout"
  }
}
resource "aws_ecs_cluster" "rookout" {
  count = var.create_cluster ? 1 : 0
  name  = "${var.environment}-ecs-cluster"

  tags = local.tags
}

data "aws_ecs_cluster" "provided" {
  count        = var.create_cluster ? 0 : 1
  cluster_name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "rookout" {
  name_prefix = var.environment
}

resource "aws_cloudwatch_log_group" "demo" {
  count       = var.deploy_demo_app ? 1 : 0
  name_prefix = "${var.environment}-demo"
}
