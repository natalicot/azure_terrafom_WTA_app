
# Configure the loadBalancer
resource "azurerm_lb" "BackLb" {
 name                = "loadBalanceBackr"
 location            = azurerm_resource_group.WTA_recource.location
 resource_group_name = azurerm_resource_group.WTA_recource.name

 frontend_ip_configuration {
   name                 = "PrivateIPForLB"
   subnet_id = azurerm_subnet.WTA_Private_SN.id
   private_ip_address_allocation = "Static"
   private_ip_address = "10.0.2.10"
 }
}

# Configure backend adress pull for loadBalancer
resource "azurerm_lb_backend_address_pool" "poolBack" {
 resource_group_name = azurerm_resource_group.WTA_recource.name
 loadbalancer_id     = azurerm_lb.BackLb.id
 name                = "BackEndAddressPool"
}

# Associating the network interface to the loadBalancer backend adress pull
resource "azurerm_network_interface_backend_address_pool_association" "associationBack" {
  count = 3
  network_interface_id    = element(azurerm_network_interface.WTA_Private_IF.*.id, count.index)
  ip_configuration_name   = "internal"
  backend_address_pool_id = element(azurerm_lb_backend_address_pool.poolBack.*.id, count.index)
}

# Configure loadBalancer health probe
resource "azurerm_lb_probe" "lb_back_probe" {
  resource_group_name = azurerm_resource_group.WTA_recource.name
  loadbalancer_id     = azurerm_lb.BackLb.id
  name                = "tcp-running-probe"
  port                = 5432
}

# Configure loadBalancer rule
resource "azurerm_lb_rule" "lb_rule_back" {
  resource_group_name            = azurerm_resource_group.WTA_recource.name
  loadbalancer_id                = azurerm_lb.BackLb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 5432
  backend_port                   = 5432
  frontend_ip_configuration_name = azurerm_lb.BackLb.frontend_ip_configuration[0].name
  probe_id = azurerm_lb_probe.lb_back_probe.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.poolBack.id
}