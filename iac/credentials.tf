# Defines the required local variables.
locals {
  privateKeyFilename  = pathexpand(var.privateKeyFilename)
}

# Defines the default token for the K3S cluster.
resource "random_string" "clusterToken" {
  length = 15
}

# Generates the SSH private key to secure the remote connection to the K3S cluster nodes.
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