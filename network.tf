resource "aws_security_group" "web_app_sg" {
  name_prefix = "web_app_sg"
  vpc_id      = aws_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_route_table" "default_rt" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_igw.id
  }
}

resource "aws_route_table_association" "subnet_associations" {
  count          = length(local.subnet_ids)
  subnet_id      = element(local.subnet_ids, count.index)
  route_table_id = aws_route_table.default_rt.id
}
