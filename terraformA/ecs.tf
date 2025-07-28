data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "strapi_sg_kg" {
  name        = "strapi-sg-kg"
  description = "Allow Strapi traffic (KG)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Use existing CloudWatch log group
data "aws_cloudwatch_log_group" "strapi_kg" {
  name = "/ecs/strapi-kg"
}

resource "aws_ecs_cluster" "strapi_kg" {
  name = "strapi-cluster-kg"
}

resource "aws_ecs_task_definition" "strapi_kg" {
  family                   = "strapi-task-kg"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = "arn:aws:iam::607700977843:role/ecs-task-execution-role"

  container_definitions = jsonencode([
    {
      name      = "strapi"
      image     = "${data.aws_ecr_repository.strapi_kg.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = data.aws_cloudwatch_log_group.strapi_kg.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "strapi_kg" {
  name            = "strapi-service-kg"
  cluster         = aws_ecs_cluster.strapi_kg.id
  task_definition = aws_ecs_task_definition.strapi_kg.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = slice(data.aws_subnets.default.ids, 0, 2)
    assign_public_ip = true
    security_groups  = [aws_security_group.strapi_sg_kg.id]
  }
}

