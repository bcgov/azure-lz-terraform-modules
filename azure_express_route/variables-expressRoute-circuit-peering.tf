variable "peering_type" {
  description = "(Required) The type of the ExpressRoute Circuit Peering."
  type        = string

  validation {
    condition     = contains(["AzurePublicPeering", "AzurePrivatePeering", "MicrosoftPeering"], var.peering_type)
    error_message = "The peering type must be either AzurePublicPeering, AzurePrivatePeering or MicrosoftPeering."
  }
}

variable "vlan_id" {
  description = "(Required) A valid VLAN ID to establish this peering on."
  type        = number
}

variable "primary_peer_address_prefix" {
  description = "(Optional) A /30 subnet for the primary link. Required when config for IPv4."
  type        = string
}

variable "secondary_peer_address_prefix" {
  description = "(Optional) A /30 subnet for the secondary link. Required when config for IPv4."
  type        = string
}

variable "ipv4_enabled" {
  description = "(Optional) A boolean value indicating whether the IPv4 peering is enabled."
  type        = bool
  default     = true
}

variable "shared_key" {
  description = "(Optional) The shared key. Can be a maximum of 25 characters."
  type        = string
  default     = null
}

variable "peer_asn" {
  description = "(Optional) The Either a 16-bit or a 32-bit ASN. Can either be public or private."
  type        = number
  default     = null
}

variable "microsoft_peering_config" {
  description = "(Optional) A microsoft_peering_config block as defined below."
  type = object({
    advertised_public_prefixes = list(string)
    customer_asn               = optional(number)
    routing_registry_name      = optional(string)
    advertised_communities     = optional(list(string))
  })
  default = null
}

variable "route_filter_id" {
  description = "(Optional) The ID of the Route Filter. Only available when peering_type is set to MicrosoftPeering."
  type        = string
  default     = null

  validation {
    condition     = var.peering_type == "MicrosoftPeering" && var.route_filter_id == null
    error_message = "The route_filter_id must be set when peering_type is set to MicrosoftPeering."
  }
}