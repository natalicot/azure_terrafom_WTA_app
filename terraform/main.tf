
# Configure the Microsoft Azure Provider
terraform {
  required_providers {
     azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
     }
    }
}

provider "azurerm" {
  features {}
  subscription_id = var.Subscription_Id
}

# Configure recource group
resource "azurerm_resource_group" "WTA_recource" {
  name     = var.Resource_Group_Name
  location = var.Location
}

#configure virtual network
resource "azurerm_virtual_network" "WTA_network" {
  name                = "WTA_network"
  address_space       = [var.VNet_CIDR]
  location            = azurerm_resource_group.WTA_recource.location
  resource_group_name = azurerm_resource_group.WTA_recource.name
}


#trying to get the old password with a for loop - failed
#  output "Server_Paswword" {
#    value = [ for i in azurerm_virtual_machine.Server.os_profile.1 : {
#     value = i.admin_password
#     }
#   ]
# }

# Outputing the outo genereted password :)
output "password" {
  description = "The password is:" 
  value = random_password.password.*.result
}


