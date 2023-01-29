# Definition of Azure provider.
provider "azurerm" {
  features {}
  subscription_id = var.azure.subscription
  tenant_id       = var.azure.tenant
}

# Definition of Azure Resources Group.
resource "azurerm_resource_group" "application" {
  name     = var.application.label
  location = var.azure.region
}

# Definition of Azure Virtual Network.
resource "azurerm_virtual_network" "application" {
  name                = "${var.application.label}-vnet"
  address_space       = [ "192.168.0.0/16" ]
  resource_group_name = azurerm_resource_group.application.name
  location            = azurerm_resource_group.application.location
}

# Definition of Azure Subnet.
resource "azurerm_subnet" "application" {
  name                 = "${var.application.label}-lan"
  address_prefixes     = [ "192.168.1.0/24" ]
  virtual_network_name = azurerm_virtual_network.application.name
  resource_group_name  = azurerm_resource_group.application.name
}

# Definition of Azure Security Group.
resource "azurerm_network_security_group" "application" {
  name                = "${var.application.label}-firewall"
  resource_group_name = azurerm_resource_group.application.name
  location            = azurerm_resource_group.application.location

  security_rule {
    name                       = var.application.label
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Definition of Azure Subnet and Security Group association.
resource "azurerm_subnet_network_security_group_association" "application" {
  subnet_id                 = azurerm_subnet.application.id
  network_security_group_id = azurerm_network_security_group.application.id
  depends_on                = [ azurerm_resource_group.application ]
}

# Definition of Azure Public IP allocation.
resource "azurerm_public_ip" "application" {
  name                = "${var.application.label}-wan"
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.application ]
}

# Definition of Azure Network Interface.
resource "azurerm_network_interface" "application" {
  name                = "${var.application.label}-nic"
  resource_group_name = azurerm_resource_group.application.name
  location            = azurerm_resource_group.application.location
  depends_on          = [ azurerm_resource_group.application ]

  ip_configuration {
    name                          = "${var.application.label}-ips"
    subnet_id                     = azurerm_subnet.application.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.application.id
  }
}

# Definition of Azure Virtual Machine
resource "azurerm_linux_virtual_machine" "worker" {
  name                  = var.azure.worker.label
  resource_group_name   = azurerm_resource_group.application.name
  location              = azurerm_resource_group.application.location
  size                  = var.azure.worker.type
  admin_username        = var.azure.worker.user
  network_interface_ids = [ azurerm_network_interface.application.id ]
  depends_on            = [ linode_instance.manager ]

  # Definition of the remote access credentials.
  admin_ssh_key {
    username   = var.azure.worker.user
    public_key = var.application.publicKey
  }

  # Definition of the disk.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Definition of the OS.
  source_image_reference {
    publisher = var.azure.worker.os.vendor
    offer     = var.azure.worker.os.id
    sku       = var.azure.worker.os.version
    version   = "latest"
  }

  # Install the Kubernetes distribution (K3S) after the provisioning.
  provisioner "remote-exec" {
    # Node connection definition.
    connection {
      host        = self.public_ip_address
      user        = var.azure.worker.user
      private_key = var.application.privateKey
    }

    # Installation script.
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt -y update",
      "sudo DEBIAN_FRONTEND=noninteractive apt -y upgrade",
      "sudo DEBIAN_FRONTEND=noninteractive apt -y install bash ca-certificates curl wget htop dnsutils net-tools vim unzip",
      "curl -sfL https://get.k3s.io | sudo K3S_TOKEN=${var.application.token} K3S_URL=https://${linode_instance.manager.ip_address}:6443 INSTALL_K3S_EXEC=agent sh -s - --node-external-ip=${self.public_ip_address}"
    ]
  }
}