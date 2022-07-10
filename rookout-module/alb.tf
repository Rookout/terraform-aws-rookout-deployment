
################################################################################
# Rookout controller ALB resources 
################################################################################
resource "aws_alb" "controller" {

  name               = "rookout-controller-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_controller.id]
  subnets            = var.create_vpc ? module.vpc[0].public_subnets : var.vpc_public_subnets
  tags               = local.tags
}

resource "aws_lb_target_group" "controller" {

  name        = local.controller_settings.container_name
  port        = local.controller_settings.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc[0].vpc_id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}


resource "aws_lb_listener" "controller" {

  load_balancer_arn = aws_alb.controller.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.controller.arn
  }
}

resource "aws_security_group" "alb_controller" {

  name        = "${local.controller_settings.container_name}-alb"
  description = "Allow inbound/outbound traffic for Rookout controller"
  vpc_id      = module.vpc[0].vpc_id
  ingress {
    description = "Inbound from IGW to controller"
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

################################################################################
# Rookout datastore ALB resources 
################################################################################


resource "aws_alb" "datastore" {
  count = var.deploy_datastore ? 1 : 0

  name               = "rookout-datastore-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_datastore[0].id]
  subnets            = var.create_vpc ? module.vpc[0].public_subnets : var.vpc_public_subnets
  tags               = local.tags
}
resource "aws_lb_target_group" "datastore" {
  count = var.deploy_datastore ? 1 : 0

  name        = local.datastore_settings.container_name
  port        = local.datastore_settings.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc[0].vpc_id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}

resource "aws_lb_listener" "datastore" {
  count = var.deploy_datastore ? 1 : 0

  load_balancer_arn = aws_alb.datastore[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.datastore[0].arn
  }
}

resource "aws_security_group" "alb_datastore" {
  count = var.deploy_datastore ? 1 : 0

  name        = "${local.datastore_settings.container_name}-alb"
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

################################################################################
# Rookout demo flask application ALB resources 
################################################################################

resource "aws_alb" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  name               = "rookout-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_demo[0].id]
  subnets            = var.create_vpc ? module.vpc[0].public_subnets : var.vpc_public_subnets
  tags               = local.tags
}

resource "aws_lb_target_group" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  name        = local.demo_settings.container_name
  port        = local.demo_settings.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc[0].vpc_id
  health_check {
    protocol = "HTTP"
    path     = "/"
  }
}


resource "aws_lb_listener" "demo" {
  count = var.deploy_demo_app ? 1 : 0

  load_balancer_arn = aws_alb.demo[0].arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.demo[0].arn
  }
}

resource "aws_security_group" "alb_demo" {
  count = var.deploy_demo_app ? 1 : 0

  name        = "${local.demo_settings.container_name}-alb"
  description = "Allow inbound/outbound traffic for Rookout demo application"
  vpc_id      = module.vpc[0].vpc_id
  ingress {
    description = "Inbound from IGW to demo application"
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