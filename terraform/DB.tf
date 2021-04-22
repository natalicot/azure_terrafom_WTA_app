
# Configure DB Subnet
resource "azurerm_subnet" "WTA_Private_SN" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.WTA_recource.name
  virtual_network_name = azurerm_virtual_network.WTA_network.name
  address_prefixes     = ["10.0.2.0/24"]
}


# Configure DB network interface
resource "azurerm_network_interface" "WTA_Private_IF" {
  count               = 1
  name                = "WTA_Private_intarface-${count.index}"
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.WTA_Private_SN.id
    private_ip_address_allocation = "Dynamic"
    # uncomment only if you are at working progress and would like the DB to hava a public ip
    # public_ip_address_id = element(azurerm_public_ip.WTA_PublicIPDB.*.id, count.index)
  }
}

# uncomment only if you are at working progress and would like the DB to hava a public ip
# Configure a public IP - Only for working progress
# resource "azurerm_public_ip" "WTA_PublicIPDB" {
#     count = 3
#     name                         = "myPublicIP-${count.index}"
#     location                     = azurerm_resource_group.WTA_recource.location
#     resource_group_name          = azurerm_resource_group.WTA_recource.name
#     allocation_method            = "Dynamic"

# }

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "DB_SG_NI" {
    count = 1
    network_interface_id      = element(azurerm_network_interface.WTA_Private_IF.*.id, count.index)
    network_security_group_id = element(azurerm_network_security_group.DB_SG.*.id, count.index)
}

# Configure DB security group
resource "azurerm_network_security_group" "DB_SG" {
    count = 1
    name                = "DB_SG_${count.index}"
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
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Configure server avilability set
resource "azurerm_availability_set" "DB-avilabilitySet" {
  name                = "DB-avilabilitySet"
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name
}


# Configure DB
resource "azurerm_virtual_machine" "DB" {
  count = 1
  name                  = "DB_${count.index}"
  location              = azurerm_resource_group.WTA_recource.location
  resource_group_name   = azurerm_resource_group.WTA_recource.name
  availability_set_id = azurerm_availability_set.DB-avilabilitySet.id
  network_interface_ids = [
    element(azurerm_network_interface.WTA_Private_IF.*.id, count.index),
  ]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1_${count.index}"
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

 
# Running DB entry Point script
resource "azurerm_virtual_machine_extension" "entryPointScriptDB" {
  count = 1
  name                 = "hostnameDB_${count.index}"
  virtual_machine_id   = element(azurerm_virtual_machine.DB.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

 settings = <<SETTINGS
  {
  "fileUris": ["https://raw.githubusercontent.com/natalicot/WTA_entryPoint/master/entryPointDB.sh"],
    "commandToExecute": "sh entryPointDB.sh"
  }
SETTINGS

}