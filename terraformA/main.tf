# Use existing ECR repository (reference only)
data "aws_ecr_repository" "strapi_kg" {
  name = var.ecr_repo_name
}

