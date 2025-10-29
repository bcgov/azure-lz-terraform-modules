output "vpn_gateway_connection_ids" {
  description = "A map of VPN Gateway Connection IDs keyed by their names."
  value       = { for name, conn in azurerm_vpn_gateway_connection.this : name => conn.id }
}

output "vpn_gateway_connection_names" {
  description = "A list of VPN Gateway Connection names."
  value       = [for conn in azurerm_vpn_gateway_connection.this : conn.name]
}

output "vpn_gateway_connection_remote_vpn_site_ids" {
  description = "A map of Remote VPN Site IDs keyed by VPN Gateway Connection names."
  value       = { for name, conn in azurerm_vpn_gateway_connection.this : name => conn.remote_vpn_site_id }
}

output "vpn_gateway_connection_vpn_gateway_ids" {
  description = "A map of VPN Gateway IDs keyed by VPN Gateway Connection names."
  value       = { for name, conn in azurerm_vpn_gateway_connection.this : name => conn.vpn_gateway_id }
}

output "vpn_gateway_connection_vpn_links" {
  description = "A map of VPN Link configurations keyed by VPN Gateway Connection names."
  value       = { for name, conn in azurerm_vpn_gateway_connection.this : name => conn.vpn_link }
}

output "vpn_gateway_connection_internet_security_enabled" {
  description = "A map indicating if Internet Security is enabled for each VPN Gateway Connection, keyed by their names."
  value       = { for name, conn in azurerm_vpn_gateway_connection.this : name => conn.internet_security_enabled }
}

output "vpn_gateway_connection_routings" {
  description = "A map of Routing configurations keyed by VPN Gateway Connection names."
  value       = { for name, conn in azurerm_vpn_gateway_connection.this : name => conn.routing }
}

output "vpn_gateway_connection_traffic_selector_policies" {
  description = "A map of Traffic Selector Policy configurations keyed by VPN Gateway Connection names."
  value       = { for name, conn in azurerm_vpn_gateway_connection.this : name => conn.traffic_selector_policy }
}
