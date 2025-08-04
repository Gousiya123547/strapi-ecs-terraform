resource "aws_ecs_cluster" "strapi_cluster" {
  name = "strapi-cluster-${var.env}"
}

resource "aws_ecs_task_definition" "strapi_task" {
  family                   = "strapi-task-${var.env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_exec.arn
  container_definitions = jsonencode([
    {
      name  = "strapi"
      image = var.image_uri
      essential = true
      portMappings = [{
        containerPort = 1337
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/strapi-${var.env}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "strapi_service" {
  name            = "strapi-service-${var.env}"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups = [aws_security_group.strapi_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg_blue.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

