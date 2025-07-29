#############################################
# Data Sources
#############################################

# Default VPC
data "aws_vpc" "default" {
  default = true
}

# Default Subnets in the VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Existing Security Group
data "aws_security_group" "strapi_sg_kg" {
  filter {
    name   = "group-name"
    values = ["strapi-sg-kg"]
  }
  vpc_id = data.aws_vpc.default.id
}

# Existing CloudWatch Log Group
data "aws_cloudwatch_log_group" "strapi_kg" {
  name = "/ecs/strapi-kg"
}

# Existing ECR repository
data "aws_ecr_repository" "strapi_kg" {
  name = var.ecr_repo_name
}

#############################################
# ECS Cluster
#############################################
resource "aws_ecs_cluster" "strapi_kg" {
  name = "strapi-cluster-kg"
}

#############################################
# ECS Task Definition
#############################################
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

#############################################
# ECS Service (with FARGATE_SPOT)
#############################################
resource "aws_ecs_service" "strapi_kg" {
  name            = "strapi-service-kg"
  cluster         = aws_ecs_cluster.strapi_kg.id
  task_definition = aws_ecs_task_definition.strapi_kg.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [data.aws_security_group.strapi_sg_kg.id]
  }

  depends_on = [aws_ecs_task_definition.strapi_kg]
}

