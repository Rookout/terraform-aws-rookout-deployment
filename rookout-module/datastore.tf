locals {
    datastore_name        = "rookout-datastore"
    datastore_port = 8080
    datastore_settings = {
        container_name            = "rookout-datastore"
        task_cpu = 512
        task_memory = 1024
        onprem_enabled = true
        dop_no_ssl_verify = true
        server_mode = "PLAIN"
        container_cpu             = 256
        container_memory          = 512
        container_port            = 8080
        load_balancer_port        = 8080
        storage_size              = 21
        datastore_in_memory_db = false
    }
    
    datastore_definition = templatefile(("${path.module}/templates/datastore_task_def.tpl"), {
        name                      = local.datastore_settings.container_name
        cpu                       = local.datastore_settings.container_cpu
        memory                    = local.datastore_settings.container_memory
        port                      = local.datastore_port
        log_group                 = aws_cloudwatch_log_group.rookout.name
        log_stream                = aws_cloudwatch_log_stream.datastore_log_stream.name
        aws_region                = var.region
        rookout_token_arn         = var.rookout_token_arn == "" ? "${data.aws_secretsmanager_secret.rookout_token[0].arn}:${var.secret_key}::" : "${var.rookout_token_arn}:${var.secret_key}::"
        datastore_server_mode    = "PLAIN"
        onprem_enabled            = local.datastore_settings.onprem_enabled
        dop_no_ssl_verify         = local.datastore_settings.dop_no_ssl_verify
        datastore_in_memory_db    = local.datastore_settings.datastore_in_memory_db
   })
  
}

resource "aws_ecs_task_definition" "datastore" {

  family                   = local.datastore_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.datastore_settings.task_cpu
  memory                   = local.datastore_settings.task_memory
  execution_role_arn       = aws_iam_role.task_exec_role.arn
  task_role_arn            = aws_iam_role.task_exec_role.arn
  container_definitions    = local.datastore_definition

  ephemeral_storage {
      size_in_gib = local.datastore_settings.storage_size
    }
  
}

resource "aws_ecs_service" "datastore" {

  name            = local.datastore_name
  cluster         = var.create_cluster ? aws_ecs_cluster.rookout[0].id : data.aws_ecs_cluster.provided[0].id
  task_definition = aws_ecs_task_definition.datastore.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  load_balancer {
      target_group_arn = aws_lb_target_group.datastore.arn
      container_name   = local.datastore_settings.container_name
      container_port   = local.datastore_settings.container_port
    }

  network_configuration {
    security_groups  = [aws_security_group.allow_datastore.id]
    subnets          = module.vpc[0].private_subnets
  }
}

resource "aws_cloudwatch_log_stream" "datastore_log_stream" {
  name           = "rookout-datastore"
  log_group_name = aws_cloudwatch_log_group.rookout.name
}

# Network

 resource "aws_alb" "datastore" {

   name               = "rookout-datastore-alb"
   internal           = false
   load_balancer_type = "application"
   security_groups    = [aws_security_group.alb_datastore.id]
   subnets            = module.vpc[0].public_subnets
   tags = local.tags
 }
resource "aws_lb_target_group" "datastore" {

  name        = local.datastore_name
  port        = local.datastore_port
  protocol    = "HTTP"  
  target_type = "ip"
  vpc_id      = module.vpc[0].vpc_id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

resource "aws_lb_listener" "datastore" {

  load_balancer_arn = aws_alb.datastore.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.datastore.arn
  }
}

resource "aws_security_group" "allow_datastore" {

  name        = local.datastore_name
  description = "Allow inbound/outbound traffic for Rookout datastore"
  vpc_id      = module.vpc[0].vpc_id
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

resource "aws_security_group" "alb_datastore" {

  name        = "${local.datastore_name}-alb"
  description = "Allow inbound/outbound traffic for Rookout datastore"
  vpc_id      = module.vpc[0].vpc_id
  ingress {
    description = "Inbound from IGW to datastore"
    from_port   = 443
    to_port     = 443
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