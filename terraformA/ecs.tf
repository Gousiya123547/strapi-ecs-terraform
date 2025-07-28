data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Use existing security group
data "aws_security_group" "strapi_sg_kg" {
  filter {
    name   = "group-name"
    values = ["strapi-sg-kg"]
  }
  vpc_id = data.aws_vpc.default.id
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

# Reference existing ECS service (correct data source)
data "aws_ecs_service" "strapi_kg" {
  cluster_arn  = aws_ecs_cluster.strapi_kg.arn
  service_name = "strapi-service-kg"
}

