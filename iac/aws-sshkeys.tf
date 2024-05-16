# Definition of the SSH public key stored in the AWS nodes.
resource "aws_key_pair" "default" {
  key_name   = local.settings.tag
  public_key = tls_private_key.default.public_key_openssh

  tags = {
    Name = local.settings.tag
  }

  depends_on = [ tls_private_key.default ]
}