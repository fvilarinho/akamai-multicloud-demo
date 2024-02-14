# Defines the required local variables.
locals {
  privateKeyFilename  = pathexpand(var.privateKeyFilename)
}

# Defines the default password for the K3S cluster nodes.
resource "random_password" "default" {
  length = 15
}

# Defines the default token for the K3S cluster.
resource "random_string" "clusterToken" {
  length = 15
}

# Generates the SSH private key to secure the remote connection to the nodes.
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Saves the SSH private key locally.
resource "local_sensitive_file" "privateKey" {
  filename        = local.privateKeyFilename
  content         = tls_private_key.default.private_key_openssh
  file_permission = "600"
  depends_on      = [ tls_private_key.default ]
}

# Definition of the public key stored in the Linode nodes.
resource "linode_sshkey" "default" {
  label      = var.identifier
  ssh_key    = chomp(tls_private_key.default.public_key_openssh)
  depends_on = [ tls_private_key.default ]
}

# Definition of the public key stored in the AWS nodes.
resource "aws_key_pair" "default" {
  key_name   = var.identifier
  public_key = tls_private_key.default.public_key_openssh

  tags = {
    Name = var.identifier
  }

  depends_on = [ tls_private_key.default ]
}