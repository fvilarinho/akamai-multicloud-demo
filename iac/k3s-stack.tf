# Apply the stack in the K3S cluster.
resource "null_resource" "applyStack" {
  triggers = {
    always_run = timestamp()
  }

  # Execute the apply script.
  provisioner "local-exec" {
    environment = {
      USER         = local.settings.linode.manager.user
      MANAGER_NODE = linode_instance.manager.ip_address
    }

    quiet = true
    command = "./k3sStack.sh"
  }

  depends_on = [
    linode_instance.manager,
    linode_instance.worker,
    aws_instance.worker
  ]
}