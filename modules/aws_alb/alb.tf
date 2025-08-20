# 외부 ALB (Public)
resource "aws_lb" "ex_alb" {
  name               = "${var.project_name}-${var.environment}-ex-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.ex_alb_sg_id]

  subnets= values(var.public_subnet_ids)

  idle_timeout               = 60
  enable_deletion_protection = false
  ip_address_type            = "ipv4"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Role        = "alb-external"
  }
}

# 내부 ALB (Private)
resource "aws_lb" "in_alb" {
  name               = "${var.project_name}-${var.environment}-in-alb"
  load_balancer_type = "application"
  internal           = true
  security_groups    = [var.in_alb_sg_id]

  subnets= values(var.private_subnet_ids)


  idle_timeout               = 60
  enable_deletion_protection = false
  ip_address_type            = "ipv4"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Role        = "alb-internal"
  }
}

# Target Group (예: 내부 앱 8080, HTTP)
resource "aws_lb_target_group" "alb_tg" {
  name        = "${var.project_name}-${var.environment}-alb-tg"
  port        = var.port
  protocol    = var.protocol 
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol = var.protocol
    path     = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 5
    matcher  = "200-399"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# 외부 ALB Listener : 80 → TG로 포워드
resource "aws_lb_listener" "ex_alb_http_80" {
  load_balancer_arn = aws_lb.ex_alb.arn
  port              = 80
  protocol          = var.protocol 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_listener" "in_alb_http_80" {
  load_balancer_arn = aws_lb.in_alb.arn
  port              = 80
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_private" {
  for_each         = var.target_instance_map
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = each.value
  port             = var.port
}
