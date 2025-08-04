data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "details" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

locals {
  subnets_by_az = {
    for subnet_id, subnet in data.aws_subnet.details :
    subnet.availability_zone => subnet.id...
  }

  selected_subnets = [
    for az, subnets in local.subnets_by_az : subnets[0]
  ]
}

