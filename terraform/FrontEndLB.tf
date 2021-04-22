
# Configure a public Ip for loadBalancer
resource "azurerm_public_ip" "PubIp" {
 name                         = "publicIPForLB"
 location                     = azurerm_resource_group.WTA_recource.location
 resource_group_name          = azurerm_resource_group.WTA_recource.name
 allocation_method            = "Static"
}

# Configure the loadBalancer
resource "azurerm_lb" "FrontLb" {
 name                = "loadBalancerFront"
 location            = azurerm_resource_group.WTA_recource.location
 resource_group_name = azurerm_resource_group.WTA_recource.name

 frontend_ip_configuration {
   name                 = "publicIPForLB"
   public_ip_address_id = azurerm_public_ip.PubIp.id
 }
}

# Configure backend adress pull for loadBalancer
resource "azurerm_lb_backend_address_pool" "pool" {
 resource_group_name = azurerm_resource_group.WTA_recource.name
 loadbalancer_id     = azurerm_lb.FrontLb.id
 name                = "FrontEndAddressPool"
}

# Associating the network interface to the loadBalancer backend adress pull
resource "azurerm_network_interface_backend_address_pool_association" "association" {
  count = 3
  network_interface_id    = element(azurerm_network_interface.WTA_Public_IF.*.id, count.index)
  ip_configuration_name   = "external"
  backend_address_pool_id = element(azurerm_lb_backend_address_pool.pool.*.id, count.index)
}

# Configure loadBalancer health probe
resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = azurerm_resource_group.WTA_recource.name
  loadbalancer_id     = azurerm_lb.FrontLb.id
  name                = "http-running-probe"
  port                = 8080
}

# Configure loadBalancer rule
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = azurerm_resource_group.WTA_recource.name
  loadbalancer_id                = azurerm_lb.FrontLb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "publicIPForLB"
  probe_id = azurerm_lb_probe.lb_probe.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}