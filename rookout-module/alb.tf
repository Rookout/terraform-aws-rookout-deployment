 resource "aws_alb" "rookout" {
   count = var.create_alb ? 1 : 0

   name               = "rookout-alb"
   internal           = false
   load_balancer_type = "application"
   security_groups    = [aws_security_group.allow_alb[0].id]
   subnets            = module.vpc[0].public_subnets
   tags               = {
       terraform = true
       Environment = "rookout"
   }
 }

 resource "aws_security_group" "allow_alb" {
   count = var.create_alb ? 1 : 0

   name        = "alb-rookout-sg"
   description = "Allow inbound/outbound traffic for Application Load Balancer"
   vpc_id      = module.vpc[0].vpc_id

   ingress {
     description = "Inbound from IGW to controller"
     from_port   = 7488
     to_port     = 7488
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }
   egress {
     description      = "Outbound all"
     from_port        = 0
     to_port          = 0
     protocol         = "-1"
     cidr_blocks      = ["0.0.0.0/0"]
   }
   tags = {
       terraform = true
       Environment = "rookout"
   }
 } 

