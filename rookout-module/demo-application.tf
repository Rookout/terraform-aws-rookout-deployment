
locals {
  demo_settings = {
    container_name     = "rookout-tutorial-python"
    task_cpu           = 512
    task_memory        = 1024
    container_cpu      = 512
    container_memory   = 512
    container_port     = 5000
    load_balancer_port = 443
  }

  demo_definition = templatefile(("${path.module}/templates/demo_application_task_def.tpl"), {
    name                = local.demo_settings.container_name
    cpu                 = local.demo_settings.container_cpu
    memory              = local.demo_settings.container_memory
    port                = local.demo_settings.container_port
    log_group           = var.deploy_demo_app ? aws_cloudwatch_log_group.demo[0].name : ""
    log_stream          = var.deploy_demo_app ? aws_cloudwatch_log_stream.demo_log_stream[0].name : ""
    aws_region          = local.region
    controller_host     = var.deploy_alb ? var.datastore_acm_certificate_arn == "" ? "wss://${aws_route53_record.controller[0].fqdn}" : var.controller_acm_certificate_arn == "" ? "ws://${aws_alb.controller[0].dns_name}" : "wss://${aws_alb.controller[0].dns_name}" : var.demo_app_controller_host
    controller_port     = var.datastore_acm_certificate_arn != ""  && var.controller_acm_certificate_arn == "" ? 80 : 443
    remote_origin       = "https://github.com/Rookout/tutorial-python.git"
    commit              = "HEAD"
    rookout_token       = var.rookout_token
    additional_env_vars = var.additional_demo_app_env_vars
  })

}


resource "aws_ecs_task_definition" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  family                   = "${local.demo_settings.container_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.demo_settings.task_cpu
  memory                   = local.demo_settings.task_memory
  execution_role_arn       = var.custom_iam_task_exec_role_arn == "" ? aws_iam_role.task_exec_role[0].arn : var.custom_iam_task_exec_role_arn
  task_role_arn            = var.custom_iam_task_exec_role_arn == "" ? aws_iam_role.task_exec_role[0].arn : var.custom_iam_task_exec_role_arn
  container_definitions    = local.demo_definition

}

resource "aws_ecs_service" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  name            = local.demo_settings.container_name
  cluster         = var.create_cluster ? aws_ecs_cluster.rookout[0].id : data.aws_ecs_cluster.provided[0].id
  task_definition = aws_ecs_task_definition.demo[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.allow_demo[0].id]
    subnets         = var.create_vpc ? module.vpc[0].private_subnets : var.vpc_private_subnets
  }
  dynamic "load_balancer" {
    for_each = var.deploy_alb || length(var.demo_app_target_group_arn) > 0 ? [1] : [0]
    content {
      target_group_arn = var.deploy_alb ? aws_lb_target_group.demo[0].arn : var.demo_app_target_group_arn
      container_name   = local.demo_settings.container_name
      container_port   = local.demo_settings.container_port
    }

  }
}


resource "aws_cloudwatch_log_stream" "demo_log_stream" {
  count          = var.deploy_demo_app ? 1 : 0
  name           = "demo"
  log_group_name = aws_cloudwatch_log_group.demo[0].name
}




resource "aws_security_group" "allow_demo" {
  count = var.deploy_demo_app ? 1 : 0

  name        = local.demo_settings.container_name
  description = "Allow inbound/outbound traffic for Rookout demo application"
  vpc_id      = module.vpc[0].vpc_id
  ingress {
    description = "Inbound from IGW to demo application"
    from_port   = local.demo_settings.container_port
    to_port     = local.demo_settings.container_port
    protocol    = "tcp"
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


