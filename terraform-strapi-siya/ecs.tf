resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-${var.env}"
}


resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-${var.env}"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  launch_type     = "FARGATE"
  desired_count   = 1

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets         = [
      data.aws_subnet.details["subnet-00149dab4a12107f1"].id,
      data.aws_subnet.details["subnet-024126fd1eb33ec08"].id,
      data.aws_subnet.details["subnet-0f270cd24889d1201"].id
    ]
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg_blue.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      network_configuration
    ]
  }
}

