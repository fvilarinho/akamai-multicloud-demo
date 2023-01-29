# Apply the stack in the application cluster nodes.
resource "null_resource" "apply-stack" {
  # Trigger definition to execute.
  triggers = {
    always_run = timestamp()
  }

  # Copy content files to the cluster nodes.
  provisioner "file" {
    source      = "../html.zip"
    destination = "/tmp/html.zip"

    # Node connection definition.
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }
  }

  provisioner "file" {
    source      = "../html.zip"
    destination = "/tmp/html.zip"

    # Node connection definition.
    connection {
      host        = linode_instance.worker.ip_address
      user        = var.linode.worker.user
      private_key = var.application.privateKey
    }
  }

  provisioner "file" {
    source      = "../html.zip"
    destination = "/tmp/html.zip"

    # Node connection definition.
    connection {
      host        = aws_instance.worker.public_ip
      user        = var.aws.worker.user
      private_key = var.application.privateKey
    }
  }

  provisioner "file" {
    source      = "../html.zip"
    destination = "/tmp/html.zip"

    # Node connection definition.
    connection {
      host        = azurerm_linux_virtual_machine.worker.public_ip_address
      user        = var.azure.worker.user
      private_key = var.application.privateKey
    }
  }

  # Upload the apply script into the manager node.
  provisioner "file" {
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    source      = "applyStack.sh"
    destination = "/tmp/applyStack.sh"
  }

  # Upload the stack file into the manager node.
  provisioner "file" {
    # Node connection definition.
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    source      = "kubernetes.yml"
    destination = "/tmp/kubernetes.yml"
  }

  # Apply the stack.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = linode_instance.worker.ip_address
      user        = var.linode.worker.user
      private_key = var.application.privateKey
    }

    inline = [
      "cd /tmp",
      "unzip -q -o html.zip",
      "rm -rf /usr/share/nginx",
      "mkdir -p /usr/share/nginx",
      "cp -rf html /usr/share/nginx"
    ]
  }

  # Apply the stack.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = aws_instance.worker.public_ip
      user        = var.aws.worker.user
      private_key = var.application.privateKey
    }

    inline = [
      "cd /tmp",
      "unzip -q -o html.zip",
      "sudo rm -rf /usr/share/nginx",
      "sudo mkdir -p /usr/share/nginx",
      "sudo cp -rf html /usr/share/nginx"
    ]
  }

  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = azurerm_linux_virtual_machine.worker.public_ip_address
      user        = var.azure.worker.user
      private_key = var.application.privateKey
    }

    inline = [
      "cd /tmp",
      "sudo unzip -q -o html.zip",
      "sudo rm -rf /usr/share/nginx",
      "sudo mkdir -p /usr/share/nginx",
      "sudo cp -rf html /usr/share/nginx"
    ]
  }

  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = linode_instance.manager.ip_address
      user        = var.linode.manager.user
      private_key = var.application.privateKey
    }

    inline = [
      "cd /tmp",
      "unzip -q -o html.zip",
      "rm -rf /usr/share/nginx",
      "mkdir -p /usr/share/nginx",
      "cp -rf html /usr/share/nginx",
      "chmod +x applyStack.sh",
      "./applyStack.sh",
      "rm -f applyStack.sh"
    ]
  }

  depends_on = [ linode_instance.manager, linode_instance.worker, aws_instance.worker, azurerm_linux_virtual_machine.worker ]
}