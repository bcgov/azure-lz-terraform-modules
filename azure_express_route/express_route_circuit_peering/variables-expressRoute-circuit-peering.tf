variable "circuit_peering" {
  description = "Express Route circuit peering configuration"
  type = list(object({
    peering_type                  = string
    express_route_circuit_name    = string
    vlan_id                       = number
    primary_peer_address_prefix   = optional(string)
    secondary_peer_address_prefix = optional(string)
    ipv4_enabled                  = optional(bool, true)
    shared_key                    = optional(string, null)
    peer_asn                      = optional(number, null)
    microsoft_peering_config = optional(object({
      advertised_public_prefixes = list(string)
      customer_asn               = optional(number, 0)
      routing_registry_name      = optional(string, "NONE")
      advertised_communities     = optional(list(string))
    }), null)
    ipv6 = optional(object({
      primary_peer_address_prefix   = string
      secondary_peer_address_prefix = string
      enabled                       = optional(bool, true)
      microsoft_peering = optional(object({
        advertised_public_prefixes = list(string)
        customer_asn               = optional(number, 0)
        routing_registry_name      = optional(string, "NONE")
        advertised_communities     = optional(list(string))
      }), null)
      route_filter_id = optional(string, null)
    }), null)
    route_filter_id = optional(string, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for peering in var.circuit_peering : contains(["AzurePrivatePeering", "AzurePublicPeering", "MicrosoftPeering"], peering.peering_type)
    ])
    error_message = "The sku tier must be either Basic, Local, Standard or Premium."
  }
}
