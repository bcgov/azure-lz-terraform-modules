variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group for the private DNS zones. This is the existing Forge DNS resource group, not a virtual WAN sidecar group."
  default     = null
}

variable "private_dns_zones" {
  type = map(object({
    private_dns_zone_name = string
    resource_group_name   = string
  }))
  description = "Private DNS zones to manage in the connectivity subscription. Empty leaves zone management to another stack."
  default     = {}
}

variable "private_dns_zone_virtual_network_links" {
  type = map(object({
    private_dns_zone_vnet_link_name = string
    private_dns_zone_name           = string
    resource_group_name             = string
    virtual_network_id              = string
    registration_enabled            = optional(bool, false)
    resolution_policy               = optional(string)
  }))
  description = "Links from those private DNS zones to the existing private DNS spoke."
  default     = {}
}
