# Creates the K3S cluster manager node.
resource "linode_instance" "manager" {
  label           = local.settings.linode.manager.name
  type            = local.settings.linode.manager.type
  region          = local.settings.linode.manager.region
  image           = local.settings.linode.manager.os
  tags            = local.settings.tags
  authorized_keys = [ linode_sshkey.default.ssh_key ]

  # Installs the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.ip_address
      user        = local.settings.linode.manager.user
      private_key = tls_private_key.default.private_key_openssh
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${local.settings.linode.manager.name}",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "export K3S_TOKEN=\"${random_string.clusterToken.result}\"",
      "export K3S_KUBECONFIG_MODE=644",
      "export INSTALL_K3S_EXEC=server",
      "curl -sfL https://get.k3s.io | sh -s - --node-external-ip=${self.ip_address} --flannel-backend=wireguard-native --flannel-external-ip"
    ]
  }
}

# Creates the K3S cluster worker node 1.
resource "linode_instance" "worker" {
  label           = local.settings.linode.worker.name
  type            = local.settings.linode.worker.type
  region          = local.settings.linode.worker.region
  image           = local.settings.linode.worker.os
  tags            = local.settings.tags
  authorized_keys = [ linode_sshkey.default.ssh_key ]

  # Installs the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.ip_address
      user        = local.settings.linode.worker.user
      private_key = tls_private_key.default.private_key_openssh
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${local.settings.linode.worker.name}",
      "export DEBIAN_FRONTEND=noninteractive",
      "apt update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "export K3S_TOKEN=\"${random_string.clusterToken.result}\"",
      "export K3S_URL=https://${linode_instance.manager.ip_address}:6443",
      "export INSTALL_K3S_EXEC=agent",
      "curl -sfL https://get.k3s.io | sh -s - --node-external-ip=${self.ip_address}"
    ]
  }

  depends_on = [ linode_instance.manager ]
}