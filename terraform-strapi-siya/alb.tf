resource "aws_lb" "strapi_alb" {
  name               = "strapi-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.strapi_sg.id]
  subnets            = [
    data.aws_subnet.details["subnet-00149dab4a12107f1"].id,
    data.aws_subnet.details["subnet-024126fd1eb33ec08"].id,
    data.aws_subnet.details["subnet-0f270cd24889d1201"].id
  ]
}

resource "aws_lb_target_group" "strapi_tg_blue" {
  name        = "strapi-tg-blue-${var.env}"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "strapi_tg_green" {
  name        = "strapi-tg-green-${var.env}"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "strapi_listener" {
  load_balancer_arn = aws_lb.strapi_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_tg_blue.arn
  }
}

