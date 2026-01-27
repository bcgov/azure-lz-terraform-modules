variable "network_manager_ipam_pool_id" {
  description = "Azure IPAM Pool ID"
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
  description = "(Required) The address space for the virtual network (ie. 24). No slash needed."
  type        = number
  default     = 24

  validation {
    condition     = var.virtual_network_address_space >= 0 && var.virtual_network_address_space <= 32 && floor(var.virtual_network_address_space) == var.virtual_network_address_space
    error_message = "The virtual_network_address_space must be a whole number between 0 and 32 (valid CIDR prefix)."
  }
}

variable "github_hosted_runners_subnet_name" {
  description = "(Required) The name of the subnet to use for the GitHub hosted runners (which will be VNet injected)"
  type        = string
  default     = "github-runners"
}

variable "github_hosted_runners_subnet_address_prefix" {
  description = "(Required) The address prefix for the GitHub hosted runners subnet (ie. 28). No slash needed."
  type        = number

  validation {
    condition     = var.github_hosted_runners_subnet_address_prefix >= 0 && var.github_hosted_runners_subnet_address_prefix <= 32 && floor(var.github_hosted_runners_subnet_address_prefix) == var.github_hosted_runners_subnet_address_prefix
    error_message = "The github_hosted_runners_subnet_address_prefix must be a whole number between 0 and 32 (valid CIDR prefix)."
  }
}
