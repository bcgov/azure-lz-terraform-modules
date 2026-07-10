variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID for connectivity resources (used to build gateway parent IDs)."
}

variable "virtual_hub_id" {
  description = "Resource ID of the Virtual Hub."
  type        = string
}

variable "virtual_hub_resource_group_name" {
  description = "Resource group name of the Virtual Hub / VPN / ExpressRoute gateways."
  type        = string
}

variable "outbound_route_map_key" {
  description = "Stable Terraform map key for the outbound route map."
  type        = string
  default     = "outbound_to_onprem"
}

variable "outbound_route_map_name" {
  description = "Azure name of the outbound route map resource."
  type        = string
  default     = "outbound-to-onprem"
}

variable "onprem_bgp_asns" {
  description = "On-premises BGP ASNs to drop from outbound advertisements (AS-Path Contains)."
  type        = list(string)
}

variable "vpn_connection_routing" {
  description = "VPN gateway connections that should receive the outbound route map via routingConfiguration."
  type = map(object({
    vpn_gateway_name    = string
    vpn_connection_name = string
  }))
  default = {}
}

variable "express_route_connection_routing" {
  description = "ExpressRoute gateway connections that should receive the outbound route map via routingConfiguration."
  type = map(object({
    express_route_gateway_name    = string
    express_route_connection_name = string
  }))
  default = {}
}

variable "associated_route_table_id" {
  description = "Hub route table ID to associate on branch connections. Defaults to the hub defaultRouteTable."
  type        = string
  default     = null
}

variable "propagated_route_table_id" {
  description = "Hub route table ID to propagate on branch connections. Defaults to the hub noneRouteTable."
  type        = string
  default     = null
}

variable "propagated_route_table_labels" {
  description = "Labels for propagatedRouteTables on branch connections."
  type        = list(string)
  default     = ["none"]
}
