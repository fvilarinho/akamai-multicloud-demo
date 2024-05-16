# Definition of the SSH public key stored in the DigitalOcean nodes.
resource "digitalocean_ssh_key" "default" {
  name       = local.settings.tag
  public_key = chomp(tls_private_key.default.public_key_openssh)
  depends_on = [ tls_private_key.default ]
}