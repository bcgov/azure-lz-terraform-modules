output "route_map_ids" {
  description = "Map of route map keys to Azure resource IDs."
  value       = module.route_maps.route_map_ids
}

output "outbound_route_map_id" {
  description = "Resource ID of the outbound-to-onprem route map."
  value       = local.outbound_route_map_id
}

output "vpn_connection_routing_ids" {
  description = "VPN connections whose routingConfiguration is managed by this module."
  value       = { for k, r in azapi_update_resource.vpn_connection_routing : k => r.id }
}

output "express_route_connection_routing_ids" {
  description = "ExpressRoute connections whose routingConfiguration is managed by this module."
  value       = { for k, r in azapi_update_resource.express_route_connection_routing : k => r.id }
}
