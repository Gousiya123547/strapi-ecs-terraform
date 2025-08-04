variable "region" {
  default = "us-east-2"
}

variable "image_uri" {
  description = "Docker image URI from ECR"
  type        = string
}

