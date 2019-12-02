resource "aws_alb" "lb" {
  internal        = var.internal
  subnets         = var.subnets
  security_groups = var.secgroups

  tags = {
    Name    = "${var.project}-load_balancer"
    Project = "${var.project}"
  }
}

resource "aws_alb_target_group" "target_group" {
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    healthy_threshold   = "2"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "5"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  tags = {
    Name    = "${var.project}-target_group"
    Project = "${var.project}"
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.target_group.id
    type             = "forward"
  }
}