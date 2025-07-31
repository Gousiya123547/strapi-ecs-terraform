variable "ecs_cluster_name" {
  type    = string
  default = "gk-st-cluster"
}

variable "service_name" {
  type    = string
  default = "gk-st-service"
}

variable "container_name" {
  type    = string
  default = "strapi"
}

variable "container_port" {
  type    = number
  default = 1337
}

variable "cpu" {
  type    = number
  default = 512
}

variable "memory" {
  type    = number
  default = 1024
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "image" {
  type = string
}

