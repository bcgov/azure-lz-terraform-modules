variable "vpn_site" {
  description = "(Required) A map of VPN Site properties."
  type = list(object({
    name                = string
    resource_group_name = string
    location            = string
    virtual_wan_id      = string
    link = optional(list(object({
      name = string
      bgp = optional(object({
        asn             = number
        peering_address = string
      }))
      fqdn          = optional(string)
      ip_address    = optional(string)
      provider_name = optional(string)
      speed_in_mbps = optional(number)
    })))
    address_cidrs = optional(list(string))
    device_model  = optional(string)
    device_vendor = optional(string)
    o365_policy = optional(object({
      traffic_category = optional(object({
        allow_endpoint_enabled    = optional(bool)
        default_endpoint_enabled  = optional(bool)
        optimize_endpoint_enabled = optional(bool)
      }))
    }))
    tags = optional(map(string))
  }))
}
