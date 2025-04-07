variable "existing_virtual_network_resource_group_name" {
  description = "(Required) The name of the resource group containing the virtual network"
  type        = string
}

variable "existing_virtual_network_name" {
  description = "(Required) The name of the existing virtual network"
  type        = string
}

variable "data_gateway_subnet_name" {
  description = "(Required) The name of the subnet to create for the Virtual Network Data Gateway"
  type        = string
}

variable "data_gateway_subnet_address_prefix" {
  description = "(Required) The address prefix for the Virtual Network Data Gateway subnet"
  type        = string
}
