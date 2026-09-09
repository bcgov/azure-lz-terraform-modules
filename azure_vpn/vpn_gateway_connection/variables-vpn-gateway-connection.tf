variable "vpn_gateway_connection" {
  description = "(Required) A list of VPN Gateway Connection configurations."
  type = list(object({
    vpn_gateway_connection_name = string
    resource_group_name         = string
    location                    = string
    remote_vpn_site_id          = string
    vpn_gateway_id              = string
    vpn_link = optional(list(object({
      name                 = string
      egress_nat_rule_ids  = optional(list(string))
      ingress_nat_rule_ids = optional(list(string))
      vpn_site_link_id     = string
      bandwidth_mbps       = optional(number)
      bgp_enabled          = optional(bool)
      connection_mode      = optional(string)
      dpd_timeout_seconds  = optional(number)
      ipsec_policy = optional(list(object({
        dh_group                 = string
        ike_encryption_algorithm = string
        ike_integrity_algorithm  = string
        encryption_algorithm     = string
        integrity_algorithm      = string
        pfs_group                = string
        sa_data_size_kb          = number
        sa_lifetime_sec          = number
      })))
      protocol                              = optional(string)
      ratelimit_enabled                     = optional(bool)
      route_weight                          = optional(number)
      shared_key                            = optional(string)
      local_azure_ip_address_enabled        = optional(bool)
      policy_based_traffic_selector_enabled = optional(bool)
      custom_bgp_address = optional(list(object({
        ip_address          = string
        ip_configuration_id = string
      })))
    })))
    internet_security_enabled = optional(bool)
    routing = optional(object({
      associated_route_table = string
      propagated_route_table = optional(object({
        route_table_ids = list(string)
        labels          = optional(list(string))
      }))
      inbound_route_map_id  = optional(string)
      outbound_route_map_id = optional(string)
    }))
    traffic_selector_policy = optional(list(object({
      local_address_ranges  = list(string)
      remote_address_ranges = list(string)
    })))
    tags = optional(map(string))
  }))
}
