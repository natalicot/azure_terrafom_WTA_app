
# Configure Server Subnet
resource "azurerm_subnet" "WTA_Public_SN" {
  name                 = "external"
  resource_group_name  = azurerm_resource_group.WTA_recource.name
  virtual_network_name = azurerm_virtual_network.WTA_network.name
  address_prefixes     = ["10.0.3.0/24"]
}


# Configure Server network interface
resource "azurerm_network_interface" "WTA_Public_IF" {
  count               = 1
  name                = "WTA_Public_intarface-${count.index}"
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.WTA_Public_SN.id
    private_ip_address_allocation = "Dynamic"
    # uncomment only if you are at working progress and would like the server to hava a public ip
    # public_ip_address_id = element(azurerm_public_ip.WTA_PublicIP.*.id, count.index)
  }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "Server_SG_NI" {
    count = 1
    network_interface_id      = element(azurerm_network_interface.WTA_Public_IF.*.id, count.index)
    network_security_group_id = element(azurerm_network_security_group.Server_SG.*.id, count.index)
}

# uncomment only if you are at working progress and would like the server to hava a public ip
# Configure a public IP - Only for working progress
# resource "azurerm_public_ip" "WTA_PublicIP" {
#     count = 3
#     name                         = "myPublicIP_${count.index}"
#     location                     = azurerm_resource_group.WTA_recource.location
#     resource_group_name          = azurerm_resource_group.WTA_recource.name
#     allocation_method            = "Dynamic"

# }

# Configure Server security group
resource "azurerm_network_security_group" "Server_SG" {
    count = 1
    name                = "Server_SG_${count.index}"
    location            = azurerm_resource_group.WTA_recource.location
    resource_group_name = azurerm_resource_group.WTA_recource.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "8080"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Generate a random password for servers
provider "random" {
}

resource "random_password" "password" {
  count = 3
  length = 16
  special = true
}

# Configure server avilability set
resource "azurerm_availability_set" "Server-avilabilitySet" {
  name                = "Server-avilabilitySet"
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name
}

# Configure Server
resource "azurerm_virtual_machine" "Server" {
  count = 1
  name                  = "Server_${count.index}"
  location              = azurerm_resource_group.WTA_recource.location
  resource_group_name   = azurerm_resource_group.WTA_recource.name
  availability_set_id = azurerm_availability_set.Server-avilabilitySet.id
  network_interface_ids = [
    element(azurerm_network_interface.WTA_Public_IF.*.id, count.index),
  ]
  vm_size               = var.VM_Size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2_${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = var.VM_Username
    admin_password = element(random_password.password.*.result, count.index)
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

 
# # Running Server entry Point script
resource "azurerm_virtual_machine_extension" "entryPointScript" {
  count = 1
  name                 = "hostname_${count.index}"
  virtual_machine_id   = element(azurerm_virtual_machine.Server.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

 settings = <<SETTINGS
  {
  "fileUris": ["https://raw.githubusercontent.com/natalicot/WTA_entryPoint/master/entryPointServer.sh"],
    "commandToExecute": "sh entryPointServer.sh"
  }
SETTINGS

}