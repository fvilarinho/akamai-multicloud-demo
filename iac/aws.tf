# Definition of AWS provider.
provider "aws" {
  access_key = var.aws.accessKey
  secret_key = var.aws.secretKey
  region     = var.aws.region
}

# Definition of AWS main VPC.
resource "aws_vpc" "application" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.application.label}-vpc"
  }
}

# Definition of AWS Internet Gateway.
resource "aws_internet_gateway" "application" {
  vpc_id = aws_vpc.application.id

  tags = {
    Name = "${var.application.label}-gateway"
  }
}

# Definition of AWS Route Table.
resource "aws_route_table" "application" {
  vpc_id = aws_vpc.application.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.application.id
  }

  tags = {
    Name = "${var.application.label}-routes"
  }
}

# Definition of AWS Subnet.
resource "aws_subnet" "application" {
  vpc_id                  = aws_vpc.application.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "${var.aws.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.application.label}-subnet"
  }
}

# Definition of AWS Route Table association.
resource "aws_route_table_association" "application" {
  subnet_id      = aws_subnet.application.id
  route_table_id = aws_route_table.application.id
}

# Definition of AWS Security Group.
resource "aws_security_group" "application" {
  name   = "${var.application.label}-firewall"
  vpc_id = aws_vpc.application.id

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
    Name = "${var.application.label}-firewall"
  }
}

# Definition of the credentials to authenticate in the cluster nodes.
resource "aws_key_pair" "application" {
  key_name   = var.application.label
  public_key = var.application.publicKey

  tags = {
    Name = var.application.label
  }
}

# Definition of the cluster nodes.
resource "aws_instance" "worker" {
  instance_type          = var.aws.worker.type
  ami                    = var.aws.worker.os
  subnet_id              = aws_subnet.application.id
  vpc_security_group_ids = [ aws_security_group.application.id ]
  key_name               = aws_key_pair.application.key_name
  monitoring             = true
  depends_on             = [ linode_instance.manager ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.public_ip
      user        = var.aws.worker.user
      private_key = var.application.privateKey
    }

    # Installation script.
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt -y update",
      "sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "curl -sfL https://get.k3s.io | sudo K3S_TOKEN=${var.application.token} K3S_URL=https://${linode_instance.manager.ip_address}:6443 INSTALL_K3S_EXEC=agent sh -s - --node-external-ip=${self.public_ip}"
    ]
  }

  tags = {
    Name = var.aws.worker.label
  }
}