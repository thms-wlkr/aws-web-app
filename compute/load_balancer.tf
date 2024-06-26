resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false     # whether the ALB is internal (false meaning it's internet-facing)
  load_balancer_type = "application"  # type of load balancer (application for HTTP/HTTPS)
  security_groups    = [aws_security_group.public_sg.id]  # security groups associated with the ALB
  subnets = [  # list of subnets where the ALB will be deployed
    aws_subnet.public_subnets["pub_subnet_1a"].id,
    aws_subnet.public_subnets["pub_subnet_1b"].id
  ]

  enable_deletion_protection = false  # disable deletion protection for the ALB (not required for this demo project)

  tags = {
    name      = "app-lb"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"

  # health check configuration for the target group
  health_check {
    path                = "/"    # path used for health checks
    protocol            = "HTTP" # protocol used for health checks
    matcher             = "200"  # expected HTTP status code for a healthy instance
    interval            = 30     # interval between health checks
    timeout             = 5      # timeout for each health check attempt
    healthy_threshold   = 2      # number of consecutive successful health checks to consider an instance healthy
    unhealthy_threshold = 2      # number of consecutive failed health checks to consider an instance unhealthy
  }
}

# define a listener for the ALB to handle incoming HTTP traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # default action for the listener (forwarding traffic to the target group)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
