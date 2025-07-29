# ---------------------------
# 1. VPC and Subnet Data
# ---------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ---------------------------
# 2. Use Existing Security Group
# ---------------------------
data "aws_security_group" "strapi_sg_kg" {
  filter {
    name   = "group-name"
    values = ["strapi-sg-kg"] # Existing SG
  }
  vpc_id = data.aws_vpc.default.id
}

# ---------------------------
# 3. Use Existing CloudWatch Log Group
# ---------------------------
data "aws_cloudwatch_log_group" "strapi_kg" {
  name = "/ecs/strapi-kg"
}

# ---------------------------
# 5. ECS Cluster
# ---------------------------
resource "aws_ecs_cluster" "strapi_kg" {
  name = "strapi-cluster-kg"
}

# ---------------------------
# 6. ECS Task Definition
# ---------------------------
resource "aws_ecs_task_definition" "strapi_kg" {
  family                   = "strapi-task-kg"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # Base Fargate
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

# ---------------------------
# 7. ECS Service (Using FARGATE_SPOT)
# ---------------------------
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
    subnets          = slice(data.aws_subnets.default.ids, 0, 2)
    assign_public_ip = true
    security_groups  = [data.aws_security_group.strapi_sg_kg.id]
  }
}

# ---------------------------
# 8. Data Source for ECS Service
# ---------------------------
data "aws_ecs_service" "strapi_kg" {
  cluster_arn  = aws_ecs_cluster.strapi_kg.arn
  service_name = aws_ecs_service.strapi_kg.name
}

