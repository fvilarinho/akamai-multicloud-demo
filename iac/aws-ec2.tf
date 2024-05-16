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
      "sudo hostnamectl set-hostname ${local.settings.aws.worker.label}",
      "sudo DEBIAN_FRONTEND=noninteractive apt update",
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