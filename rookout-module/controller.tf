
locals {
  controller_settings = {
    container_name     = "rookout-controller"
    task_cpu           = 512
    task_memory        = 1024
    onprem_enabled     = true
    dop_no_ssl_verify  = false 
    server_mode        = "PLAIN"
    container_cpu      = 256
    container_memory   = 512
    container_port     = 7488
    load_balancer_port = 7488
  }

  controller_definition = templatefile(("${path.module}/templates/controller_task_def.tpl"), {
    name                   = local.controller_settings.container_name
    cpu                    = local.controller_settings.container_cpu
    memory                 = local.controller_settings.container_memory
    port                   = local.controller_settings.container_port
    log_group              = aws_cloudwatch_log_group.rookout.name
    log_stream             = aws_cloudwatch_log_stream.controller_log_stream.name
    aws_region             = var.region
    rookout_token_arn      = var.rookout_token_arn == "" ? "${data.aws_secretsmanager_secret.rookout_token[0].arn}:${var.secret_key}::" : "${var.rookout_token_arn}:${var.secret_key}::"
    controller_server_mode = "PLAIN"
    onprem_enabled         = var.deploy_datastore ? local.controller_settings.onprem_enabled : false
    dop_no_ssl_verify      = local.controller_settings.dop_no_ssl_verify
  })

}


resource "aws_ecs_task_definition" "controller" {

  family                   = "${local.controller_settings.container_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.controller_settings.task_cpu
  memory                   = local.controller_settings.task_memory
  execution_role_arn       = aws_iam_role.task_exec_role.arn
  task_role_arn            = aws_iam_role.task_exec_role.arn
  container_definitions    = local.controller_definition

}

resource "aws_ecs_service" "controller" {

  name            = local.controller_settings.container_name
  cluster         = var.create_cluster ? aws_ecs_cluster.rookout[0].id : data.aws_ecs_cluster.provided[0].id
  task_definition = aws_ecs_task_definition.controller.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.controller.id]
    subnets         = module.vpc[0].private_subnets
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.controller.arn
    container_name   = local.controller_settings.container_name
    container_port   = local.controller_settings.container_port
  }
}


resource "aws_cloudwatch_log_stream" "controller_log_stream" {

  name           = "rookout-controller"
  log_group_name = aws_cloudwatch_log_group.rookout.name
}


resource "aws_security_group" "controller" {

  name        = local.controller_settings.container_name
  description = "Allow inbound/outbound traffic for Rookout controller"
  vpc_id      = module.vpc[0].vpc_id
  ingress {
    description = "Inbound from IGW to controller"
    from_port   = local.controller_settings.container_port
    to_port     = local.controller_settings.container_port
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

data "aws_secretsmanager_secret" "rookout_token" {
  count = var.rookout_token_arn == "" ? 1 : 0
  name  = "rookout-token"
}