variable "region" {
  default = "us-east-2"
}

variable "image_uri" {
  description = "Docker image URI from ECR"
  type        = string
}

variable "env" {
  description = "Environment or suffix for naming"
  type        = string
  default     = "siya"
}


