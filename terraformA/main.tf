# Existing commented resource:
# resource "aws_ecr_repository" "strapi_kg" {
#   name = var.ecr_repo_name
#   lifecycle {
#     prevent_destroy = true
#     ignore_changes  = [name]
#   }
# }

# Use data source instead of creating a new repository
data "aws_ecr_repository" "strapi_kg" {
  name = var.ecr_repo_name
}

