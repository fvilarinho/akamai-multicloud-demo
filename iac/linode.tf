# Linode token definition.
provider "linode" {
  token = var.linode.token
}

# Create a public key to be used by the cluster nodes.
resource "linode_sshkey" "application" {
  label   = var.application.label
  ssh_key = var.application.publicKey
}

# Create the manager node of the cluster.
resource "linode_instance" "manager" {
  label           = var.linode.manager.label
  type            = var.linode.manager.type
  image           = var.linode.manager.os
  region          = var.linode.region
  tags            = [ var.application.label ]
  private_ip      = true
  authorized_keys = [ linode_sshkey.application.ssh_key ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.linode.manager.label}",
      "apt -y update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "export K3S_TOKEN=${var.application.token}",
      "export K3S_KUBECONFIG_MODE=644",
      "export INSTALL_K3S_EXEC=server",
      "curl -sfL https://get.k3s.io | sh -s - --node-external-ip=${self.ip_address} --flannel-backend=wireguard-native --flannel-external-ip"
    ]
  }
}

# Create the worker node of the cluster.
resource "linode_instance" "worker" {
  label           = var.linode.worker.label
  type            = var.linode.worker.type
  image           = var.linode.worker.os
  region          = var.linode.region
  tags            = [ var.application.label ]
  private_ip      = true
  authorized_keys = [ linode_sshkey.application.ssh_key ]
  depends_on      = [ linode_instance.manager ]

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.ip_address
      user        = var.linode.worker.user
      private_key = var.application.privateKey
    }

    # Installation script.
    inline = [
      "hostnamectl set-hostname ${var.linode.worker.label}",
      "apt -y update",
      "apt -y upgrade",
      "apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "export K3S_TOKEN=${var.application.token}",
      "export K3S_URL=https://${linode_instance.manager.ip_address}:6443",
      "export INSTALL_K3S_EXEC=agent",
      "curl -sfL https://get.k3s.io | sh -s - --node-external-ip=${self.ip_address}"
    ]
  }
}