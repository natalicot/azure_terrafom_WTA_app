
# Configure Server Subnet
resource "azurerm_subnet" "Jenkins_Slave_SN" {
  name                 = "jenkins_Slave"
  resource_group_name  = azurerm_resource_group.WTA_recource.name
  virtual_network_name = azurerm_virtual_network.WTA_network.name
  address_prefixes     = ["10.0.7.0/24"]
}


# Configure Server network interface
resource "azurerm_network_interface" "jenkins_Slave_IF" {
  name                = "jenkins_Slave_intarface"
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name

  ip_configuration {
    name                          = "jenkins_Slave"
    subnet_id                     = azurerm_subnet.Jenkins_Slave_SN.id
    private_ip_address_allocation = "Dynamic"
    # uncomment only if you are at working progress and would like the server to hava a public ip
    #public_ip_address_id = azurerm_public_ip.jenkins_Slave_PublicIP.id
  }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "jenkins_Slave_SG_NI" {
    network_interface_id      = azurerm_network_interface.jenkins_Slave_IF.id
    network_security_group_id = azurerm_network_security_group.jenkins_Slave_SG.id
}

# uncomment only if you are at working progress and would like the server to hava a public ip
# Configure a public IP - Only for working progress
# resource "azurerm_public_ip" "jenkins_Slave_PublicIP" {
#     name                         = "JenkinsPublicIP_Slave"
#     location                     = azurerm_resource_group.WTA_recource.location
#     resource_group_name          = azurerm_resource_group.WTA_recource.name
#     allocation_method            = "Dynamic"

# }

# Configure Server security group
resource "azurerm_network_security_group" "jenkins_Slave_SG" {
    name                = "jenkins_Slave_SG"
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

# Configure Server
resource "azurerm_virtual_machine" "jenkins_Slave" {
  name                  = "jenkins_Slave_agent"
  location              = azurerm_resource_group.WTA_recource.location
  resource_group_name   = azurerm_resource_group.WTA_recource.name
  network_interface_ids = [
    azurerm_network_interface.jenkins_Slave_IF.id,
  ]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk3"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

 
# # Running Server entry Point script
resource "azurerm_virtual_machine_extension" "entryPointScriptJenkins_Slave" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_virtual_machine.jenkins_Slave.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

 settings = <<SETTINGS
  {
  "fileUris": ["https://raw.githubusercontent.com/natalicot/WTA_entryPoint/master/entryPointJenkisSlave.sh"],
    "commandToExecute": "sh entryPointJenkisSlave.sh"
  }
SETTINGS

}