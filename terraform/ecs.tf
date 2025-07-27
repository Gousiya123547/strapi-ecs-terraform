resource "random_string" "sg_suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "aws_security_group" "strapi_sg" {
  name        = "gkk-strapi-sg-${random_string.sg_suffix.result}"
  description = "Allow Strapi traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

