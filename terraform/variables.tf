variable "VM_Size" {
  type    = string
  default = "Standard_DS1_v2"
}

variable "VM_Username" {
  type    = string
  default = "testadmin"
}

variable "Resource_Group_Name" {
  type    = string
  default = "WTA_recource_group"
}

variable "Location" {
  type    = string
  default = "West Europe"
}

variable "VNet_CIDR" {
  type    = string
  default = "10.0.0.0/16"
}

variable "Subscription_Id" {
  type    = string
}