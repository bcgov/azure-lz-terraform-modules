#------------------------------------------------------------------------------
# ExpressRoute Monitoring Variables
#------------------------------------------------------------------------------

variable "expressroute_circuits" {
  type = map(object({
    circuit_name        = string
    resource_group_name = string
    bandwidth_mbps      = number
    location            = string
    provider_name       = optional(string, "Unknown")
  }))
  description = "Map of ExpressRoute circuits to monitor."

  validation {
    condition     = length(var.expressroute_circuits) > 0
    error_message = "At least one ExpressRoute circuit must be specified."
  }
}

variable "expressroute_gateways" {
  type = map(object({
    gateway_name        = string
    resource_group_name = string
  }))
  description = "Map of classic Virtual Network ExpressRoute gateways (Microsoft.Network/virtualNetworkGateways) to monitor."
  default     = {}
}

variable "virtual_hub_express_route_gateways" {
  type = map(object({
    gateway_name        = string
    resource_group_name = string
  }))
  description = "Map of vWAN hub ExpressRoute gateways (Microsoft.Network/expressRouteGateways) to monitor. This landing zone uses these, not classic virtual network gateways."
  default     = {}
}

variable "vpn_gateways" {
  type = map(object({
    gateway_name        = string
    resource_group_name = string
  }))
  description = "Map of VPN gateways to monitor (Microsoft.Network/vpnGateways, e.g. vWAN hub VPN gateways)."
  default     = {}
}

variable "azure_firewalls" {
  type = map(object({
    firewall_name       = string
    resource_group_name = string
  }))
  description = "Map of Azure Firewalls to monitor (typically the vWAN hub firewall)."
  default     = {}
}

variable "enable_expressroute_diagnostics" {
  type        = bool
  description = "Whether to enable diagnostic settings on ExpressRoute circuits and gateways."
  default     = true
}

variable "diagnostics_retention_days" {
  type        = number
  description = "Number of days to retain diagnostic logs. Set to 0 for unlimited retention."
  default     = 90
}
