# Definition of the VPC.
resource "aws_vpc" "default" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${local.settings.tag}-vpc"
  }
}

# Definition of the VPC subnet.
resource "aws_subnet" "default" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "${local.settings.aws.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.settings.tag}-subnet"
  }

  depends_on = [ aws_vpc.default ]
}

# Definition of the VPC Internet Gateway.
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.settings.tag}-gateway"
  }

  depends_on = [ aws_vpc.default ]
}

# Definition of the VPC route table.
resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "${local.settings.tag}-routes"
  }

  depends_on = [
    aws_vpc.default,
    aws_internet_gateway.default
  ]
}

# Association of the VPC route table and VPC subnet.
resource "aws_route_table_association" "application" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
  depends_on     = [
    aws_subnet.default,
    aws_route_table.default
  ]
}

# Definition of the VPC Security Group.
resource "aws_security_group" "default" {
  name   = "${local.settings.tag}-firewall"
  vpc_id = aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${local.settings.tag}-firewall"
  }

  depends_on = [ aws_vpc.default ]
}