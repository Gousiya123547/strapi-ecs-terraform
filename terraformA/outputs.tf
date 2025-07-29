output "ecs_cluster_name" {
  value = aws_ecs_cluster.strapi_kg.name
}

output "ecs_service_name_spot" {
  value = aws_ecs_service.strapi_kg_spot.name
}

output "cloudwatch_log_group" {
  value = data.aws_cloudwatch_log_group.strapi_kg.name
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.strapi_kg.repository_url
}

