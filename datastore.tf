locals {
  datastore_settings = { # TODO: configure
    container_name         = "${var.environment}-datastore"
    task_cpu               = var.datastore_resource.cpu
    task_memory            = var.datastore_resource.memory
    onprem_enabled         = true
    dop_no_ssl_verify      = true
    server_mode            = "PLAIN"
    container_cpu          = var.datastore_resource.cpu
    container_memory       = var.datastore_resource.memory
    container_port         = 8080
    load_balancer_port     = 8080
    storage_size           = 21
    datastore_in_memory_db = true
  }

  datastore_definition = templatefile(("${path.module}/templates/datastore_task_def.tpl"), {
    name                   = local.datastore_settings.container_name
    cpu                    = local.datastore_settings.container_cpu
    memory                 = local.datastore_settings.container_memory
    port                   = local.datastore_settings.container_port
    log_group              = aws_cloudwatch_log_group.rookout.name
    log_stream             = aws_cloudwatch_log_stream.datastore_log_stream[0].name
    aws_region             = local.region
    rookout_token          = var.rookout_token
    datastore_server_mode  = "PLAIN"
    onprem_enabled         = local.datastore_settings.onprem_enabled
    dop_no_ssl_verify      = local.datastore_settings.dop_no_ssl_verify
    datastore_in_memory_db = local.datastore_settings.datastore_in_memory_db
    additional_env_vars    = var.additional_datastore_env_vars
    datastore_version      = var.datastore_version
  })

}

resource "aws_ecs_task_definition" "datastore" {
  count = var.deploy_datastore ? 1 : 0

  family                   = local.datastore_settings.container_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.datastore_settings.task_cpu
  memory                   = local.datastore_settings.task_memory
  execution_role_arn       = var.custom_iam_task_exec_role_arn == "" ? aws_iam_role.task_exec_role[0].arn : var.custom_iam_task_exec_role_arn
  task_role_arn            = var.custom_iam_task_exec_role_arn == "" ? aws_iam_role.task_exec_role[0].arn : var.custom_iam_task_exec_role_arn
  container_definitions    = local.datastore_definition

  ephemeral_storage {
    size_in_gib = local.datastore_settings.storage_size
  }

}

resource "aws_ecs_service" "datastore" {
  count = var.deploy_datastore ? 1 : 0

  name            = local.datastore_settings.container_name
  cluster         = var.create_cluster ? aws_ecs_cluster.rookout[0].id : data.aws_ecs_cluster.provided[0].id
  task_definition = aws_ecs_task_definition.datastore[0].arn
  desired_count   = 1
  launch_type     = "FARGATE"
  dynamic "load_balancer" {
    for_each = var.deploy_alb || length(var.datastore_target_group_arn) > 0 ? [1] : [0]
    content {
      target_group_arn = var.deploy_alb ? aws_lb_target_group.datastore[0].arn : var.datastore_target_group_arn
      container_name   = local.datastore_settings.container_name
      container_port   = local.datastore_settings.container_port
    }

  }

  network_configuration {
    security_groups = [aws_security_group.datastore[0].id]
    subnets         = var.create_vpc ? module.vpc[0].private_subnets : var.vpc_private_subnets
  }
}

resource "aws_cloudwatch_log_stream" "datastore_log_stream" {
  count = var.deploy_datastore ? 1 : 0

  name           = "${var.environment}-datastore"
  log_group_name = aws_cloudwatch_log_group.rookout.name
}


resource "aws_security_group" "datastore" {
  count = var.deploy_datastore ? 1 : 0

  name        = local.datastore_settings.container_name
  description = "Allow inbound/outbound traffic for Rookout datastore"
  vpc_id      = var.create_vpc ? module.vpc[0].vpc_id : var.vpc_id
  ingress {
    description = "Inbound from IGW to datastore"
    from_port   = local.datastore_settings.container_port
    to_port     = local.datastore_settings.container_port
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

