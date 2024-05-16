# Creates the K3S cluster worker node 3.
resource "digitalocean_droplet" "worker" {
  name     = local.settings.digitalocean.worker.label
  tags     = [ local.settings.tag ]
  size     = local.settings.digitalocean.worker.type
  region   = local.settings.digitalocean.worker.region
  image    = local.settings.digitalocean.worker.os
  ssh_keys = [ digitalocean_ssh_key.default.id ]

  # Installs the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.ipv4_address
      user        = local.settings.digitalocean.worker.user
      private_key = tls_private_key.default.private_key_openssh
    }

    # Installation script.
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "export K3S_TOKEN=\"${random_string.clusterToken.result}\"",
      "export K3S_URL=https://${linode_instance.manager.ip_address}:6443",
      "export INSTALL_K3S_EXEC=agent",
      "curl -sfL https://get.k3s.io | sh -s - --node-external-ip=${self.ipv4_address}"
    ]
  }

  depends_on = [ digitalocean_ssh_key.default ]
}