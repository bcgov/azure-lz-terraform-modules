variable "vpn_gateway_connection_name" {
  description = "(Required) The name which should be used for this VPN Gateway Connection. Changing this forces a new VPN Gateway Connection to be created."
  type        = string
}

variable "remote_vpn_site_id" {
  description = "(Required) The ID of the remote VPN Site, which will connect to the VPN Gateway. Changing this forces a new VPN Gateway Connection to be created."
  type        = string
}

variable "vpn_gateway_id" {
  description = "(Required) The ID of the VPN Gateway that this VPN Gateway Connection belongs to. Changing this forces a new VPN Gateway Connection to be created."
  type        = string
}

variable "vpn_link" {
  description = "(Required) One or more vpn_link blocks"
  type = list(object({
    name                 = string
    egress_nat_rule_ids  = optional(list(string))
    ingress_nat_rule_ids = optional(list(string))
    vpn_site_link_id     = string
    bandwidth_mbps       = optional(number)
    bgp_enabled          = optional(bool)
    connection_mode      = optional(string)
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
  }))
}

variable "internet_security_enabled" {
  description = "(Optional) Whether Internet Security is enabled for this VPN Connection."
  type        = bool
  default     = false
}

variable "routing" {
  description = "(Optional) A routing block as defined below. If this is not specified, there will be a default route table created implicitly."
  type = object({
    associated_route_table = string
    propagated_route_table = optional(object({
      route_table_ids = list(string)
      labels          = optional(list(string))
    }))
    inbound_route_map_id  = optional(string)
    outbound_route_map_id = optional(string)
  })
  default = null
}

variable "traffic_selector_policy" {
  description = "(Optional) One or more traffic_selector_policy blocks"
  type = list(object({
    local_address_ranges  = list(string)
    remote_address_ranges = list(string)
  }))
  default = null
}
