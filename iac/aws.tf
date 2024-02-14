# AWS provider definition.
provider "aws" {
  access_key = var.awsAccessKey
  secret_key = var.awsSecretKey
  region     = local.settings.aws.region
}

# Definition of the VPC.
resource "aws_vpc" "default" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${local.settings.tag}-vpc"
  }
}

# Definition of the subnet.
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

# Definition of the Internet Gateway.
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.settings.tag}-gateway"
  }

  depends_on = [ aws_vpc.default ]
}

# Definition of the route table.
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

# Definition of the route table association.
resource "aws_route_table_association" "application" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
  depends_on     = [
    aws_subnet.default,
    aws_route_table.default
  ]
}

# Definition of the route.
resource "aws_route" "default" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.default.id
  gateway_id             = aws_internet_gateway.default.id
  depends_on             = [
    aws_subnet.default,
    aws_internet_gateway.default
  ]
}

# Definition of the security group.
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

# Creates the K3S cluster worker node 2.
resource "aws_instance" "worker" {
  instance_type               = local.settings.aws.worker.type
  ami                         = local.settings.aws.worker.os
  vpc_security_group_ids      = [ aws_security_group.default.id ]
  subnet_id                   = aws_subnet.default.id
  key_name                    = aws_key_pair.default.key_name
  associate_public_ip_address = true

  # Installs the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.public_ip
      user        = local.settings.aws.worker.user
      private_key = tls_private_key.default.private_key_openssh
    }

    # Installation script.
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt -y update",
      "sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "curl -sfL https://get.k3s.io | sudo K3S_TOKEN=\"${random_string.clusterToken.result}\" K3S_URL=https://${linode_instance.manager.ip_address}:6443 INSTALL_K3S_EXEC=agent sh -s - --node-external-ip=${self.public_ip}"
    ]
  }

  tags = {
    Name = local.settings.aws.worker.label
  }

  depends_on = [
    tls_private_key.default,
    random_string.clusterToken,
    aws_security_group.default,
    aws_subnet.default,
    aws_key_pair.default,
    linode_instance.manager
  ]
}