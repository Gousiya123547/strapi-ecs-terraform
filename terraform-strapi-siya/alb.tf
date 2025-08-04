resource "aws_lb" "strapi_alb" {
  name               = "strapi-alb-${var.env}"
  internal           = false
  load_balancer_type = "application"
  subnets            = local.selected_subnets

  security_groups    = [aws_security_group.strapi_sg.id]
}

resource "aws_lb_target_group" "strapi_tg_blue" {
  name        = "strapi-tg-blue-${var.env}"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "strapi_tg_green" {
  name        = "strapi-tg-green-${var.env}"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path = "/"
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

