variable "private_dns_zone_virtual_network_link" {
  type = map(object({
    private_dns_zone_vnet_link_name = string
    private_dns_zone_name           = string
    resource_group_name             = string
    virtual_network_id              = string
    registration_enabled            = optional(bool, false)
    # resolution_policy               = optional(string, "NxDomainRedirect") # This property is only supported in AzureRM v4.35.0 and later (but our use of the CAF has not been updated to v4 yet)
    tags = optional(map(string), {})
  }))
}
