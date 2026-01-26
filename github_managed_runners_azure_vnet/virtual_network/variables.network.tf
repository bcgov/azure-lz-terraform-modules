variable "network_manager_ipam_pool_id" {
  description = "IPAM Pool id"
  type        = string  
}

variable "virtual_network_resource_group_name" {
  description = "(Required) The name of the resource group to create the virtual network in"
  type        = string
}

variable "virtual_network_name" {
  description = "(Required) The name of the virtual network to create"
  type        = string
}

variable "virtual_network_address_space" {
  description = "(Required) The address space for the virtual network (ie. 24)"
  type        = number
  default = 24
}

variable "github_hosted_runners_subnet_name" {
  description = "(Required) The name of the subnet to use for the GitHub hosted runners (which will be VNet injected)"
  type        = string
  default = "github-runners"
}

variable "github_hosted_runners_subnet_address_prefix" {
  description = "(Required) The address prefix for the GitHub hosted runners subnet (ie. 28)"
  type        = number
}
