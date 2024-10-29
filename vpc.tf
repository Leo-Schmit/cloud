data "aws_availability_zones" "available" {}

resource "aws_vpc" "default_vpc" {
  cidr_block             = "10.0.0.0/16"
  enable_dns_support     = true
  enable_dns_hostnames   = true
  tags = {
    Name = "Terraform VPC"
  }
}

resource "aws_internet_gateway" "default_igw" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_subnet" "default_subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

locals {
  subnet_ids = aws_subnet.default_subnet[*].id
}
