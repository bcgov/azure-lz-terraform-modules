variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the VPN Site should exist. Changing this forces a new VPN Site to be created."
  type        = string
}

variable "location" {
  description = "(Required) The Azure Region where the VPN Site should exist. Changing this forces a new VPN Site to be created."
  type        = string
}

variable "vpn_site_name" {
  description = "(Required) The name which should be used for this VPN Site. Changing this forces a new VPN Site to be created."
  type        = string
}

variable "virtual_wan_id" {
  description = "(Required) The ID of the Virtual Wan where this VPN site resides in. Changing this forces a new VPN Site to be created."
  type        = string
}

variable "link" {
  description = "(Optional) One or more link blocks."
  type = list(object({
    name = string
    bgp = optional(object({
      asn             = number
      peering_address = string
    }))
    fqdn          = optional(string)
    ip_address    = optional(string)
    provider_name = optional(string)
    speed_in_mbps = optional(number)
  }))
  default = null
}

variable "address_cidrs" {
  description = "(Optional) Specifies a list of IP address CIDRs that are located on your on-premises site. Traffic destined for these address spaces is routed to your local site."
  type        = list(string)
  default     = null
}

variable "device_model" {
  description = "(Optional) The model of the VPN device."
  type        = string
  default     = null
}

variable "device_vendor" {
  description = "(Optional) The name of the VPN device vendor."
  type        = string
  default     = null
}

variable "o365_policy" {
  description = "(Optional) An o365_policy block."
  type = object({
    traffic_category = optional(object({
      allow_endpoint_enabled    = optional(bool)
      default_endpoint_enabled  = optional(bool)
      optimize_endpoint_enabled = optional(bool)
    }))
  })
  default = null
}
