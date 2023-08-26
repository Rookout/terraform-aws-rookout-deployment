
locals {
  controller_settings = {
    container_name     = "${var.environment}-controller"
    task_cpu           = var.controller_resource.cpu
    task_memory        = var.controller_resource.memory
    onprem_enabled     = true
    dop_no_ssl_verify  = false
    server_mode        = "PLAIN"
    container_cpu      = var.controller_resource.cpu
    container_memory   = var.controller_resource.memory
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
    aws_region             = local.region
    rookout_token          = var.rookout_token
    controller_server_mode = "PLAIN"
    onprem_enabled         = var.deploy_datastore ? local.controller_settings.onprem_enabled : false
    dop_no_ssl_verify      = local.controller_settings.dop_no_ssl_verify
    additional_env_vars    = var.additional_controller_env_vars
    controller_version     = var.controller_version
    controller_image       = var.controller_image
    enforce_token          = "${var.enforce_token}"
  })

}


resource "aws_ecs_task_definition" "controller" {

  family                   = "${local.controller_settings.container_name}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.controller_settings.task_cpu
  memory                   = local.controller_settings.task_memory
  execution_role_arn       = var.custom_iam_task_exec_role_arn == "" ? aws_iam_role.task_exec_role[0].arn : var.custom_iam_task_exec_role_arn
  task_role_arn            = var.custom_iam_task_exec_role_arn == "" ? aws_iam_role.task_exec_role[0].arn : var.custom_iam_task_exec_role_arn
  container_definitions    = local.controller_definition

}

resource "aws_ecs_service" "controller" {

  name            = local.controller_settings.container_name
  cluster         = var.create_cluster ? aws_ecs_cluster.rookout[0].id : data.aws_ecs_cluster.provided[0].id
  task_definition = aws_ecs_task_definition.controller.arn
  desired_count   = var.controller_replicas
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.controller.id]
    subnets         = var.create_vpc ? module.vpc[0].private_subnets : var.vpc_private_subnets
  }
  dynamic "load_balancer" {
    for_each = var.deploy_alb || length(var.controller_target_group_arn) > 0 ? [1] : [0]
    content {
      target_group_arn = var.deploy_alb ? aws_lb_target_group.controller[0].arn : var.controller_target_group_arn
      container_name   = local.controller_settings.container_name
      container_port   = local.controller_settings.container_port
    }

  }
}


resource "aws_cloudwatch_log_stream" "controller_log_stream" {

  name           = "${var.environment}-controller"
  log_group_name = aws_cloudwatch_log_group.rookout.name
}


resource "aws_security_group" "controller" {

  name        = local.controller_settings.container_name
  description = "Allow inbound/outbound traffic for Rookout controller"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  ingress {
    description = "Inbound from IGW to controller"
    from_port   = local.controller_settings.container_port
    to_port     = local.controller_settings.container_port
    protocol    = "tcp"
    cidr_blocks = var.controller_sg_igress_cidr_blocks
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