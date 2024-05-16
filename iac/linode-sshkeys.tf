# Definition of the SSH public key stored in the Linode nodes.
resource "linode_sshkey" "default" {
  label      = local.settings.tag
  ssh_key    = chomp(tls_private_key.default.public_key_openssh)
  depends_on = [ tls_private_key.default ]
}