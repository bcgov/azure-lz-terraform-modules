variable "ipam_pool_resource_group_name" {
  description = "(Required) The name of the resource group in which the Network Manager IPAM Pool should exist. Changing this forces a new Network Manager IPAM Pool to be created."
  type        = string
}

variable "ipam_pool_name" {
  description = "(Required) The name which should be used for this Network Manager IPAM Pool. Changing this forces a new Network Manager IPAM Pool to be created."
  type        = string
}

variable "ipam_pool_address_prefixes" {
  description = "(Required) Specifies a list of IPv4 or IPv6 IP address prefixes. Changing this forces a new Network Manager IPAM Pool to be created."
  type        = list(string)
}

variable "ipam_pool_description" {
  description = "(Optional) The description of the Network Manager IPAM Pool."
  type        = string
  default     = null
}

variable "ipam_pool_display_name" {
  description = "(Optional) The display name for the Network Manager IPAM Pool."
  type        = string
  default     = null

  validation {
    condition     = var.ipam_pool_display_name == null ? true : length(var.ipam_pool_display_name) >= 1 && length(var.ipam_pool_display_name) <= 64 && can(regex("^[a-zA-Z0-9_.-]+$", var.ipam_pool_display_name))
    error_message = "ipam_pool_display_name must be between 1 and 64 characters long and can only contain letters, numbers, underscores(_), periods(.), and hyphens(-)."
  }
}

variable "parent_pool_name" {
  description = "(Optional) The name of the parent IPAM Pool. Changing this forces a new Network Manager IPAM Pool to be created."
  type        = string
  default     = null
}
