variable "network_manager_name" {
  description = "(Required) Specifies the name which should be used for this Network Manager. Changing this forces a new Network Manager to be created."
  type        = string
}

variable "scope" {
  description = "(Required) Specifies the scope of the Network Manager. At least one of the nested `management_group_ids` or `subscription_ids` attributes must be set."
  type = object({
    management_group_ids = optional(list(string), null)
    subscription_ids     = optional(list(string), null)
  })
}

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
}

variable "parent_pool_name" {
  description = "(Optional) The name of the parent IPAM Pool. Changing this forces a new Network Manager IPAM Pool to be created."
  type        = string
  default     = null
}
