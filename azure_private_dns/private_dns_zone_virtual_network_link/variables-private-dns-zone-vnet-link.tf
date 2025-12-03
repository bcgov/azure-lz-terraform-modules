variable "private_dns_zone_virtual_network_link" {
  type = map(object({
    private_dns_zone_vnet_link_name = string
    private_dns_zone_name           = string
    resource_group_name             = string
    virtual_network_id              = string
    registration_enabled            = optional(bool, false)
    resolution_policy               = optional(string, "NxDomainRedirect")
    tags                            = optional(map(string), {})
  }))
}
