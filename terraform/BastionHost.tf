resource "azurerm_subnet" "BastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.WTA_recource.name
  virtual_network_name = azurerm_virtual_network.WTA_network.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_public_ip" "BastionPublicIp" {
  name                = "BastionPublicIp"
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "Bastion" {
  name                = "Bastion"
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name

  ip_configuration {
    name                 = "Bustionconfiguration"
    subnet_id            = azurerm_subnet.BastionSubnet.id
    public_ip_address_id = azurerm_public_ip.BastionPublicIp.id
  }
}