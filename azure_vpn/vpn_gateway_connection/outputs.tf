output "vpn_gateway_connection_id" {
  description = "The ID of the VPN Gateway Connection."
  value       = azurerm_vpn_gateway_connection.this.id
}

output "vpn_gateway_connection_name" {
  description = "The name of the VPN Gateway Connection."
  value       = azurerm_vpn_gateway_connection.this.name
}

output "vpn_gateway_connection_remote_vpn_site_id" {
  description = "The ID of the Remote VPN Site."
  value       = azurerm_vpn_gateway_connection.this.remote_vpn_site_id
}

output "vpn_gateway_connection_vpn_gateway_id" {
  description = "The ID of the VPN Gateway."
  value       = azurerm_vpn_gateway_connection.this.vpn_gateway_id
}

output "vpn_gateway_connection_vpn_link" {
  description = "The VPN Link configuration."
  value       = azurerm_vpn_gateway_connection.this.vpn_link
}

output "vpn_gateway_connection_internet_security_enabled" {
  description = "Is Internet Security enabled for the VPN Gateway Connection."
  value       = azurerm_vpn_gateway_connection.this.internet_security_enabled
}

output "vpn_gateway_connection_routing" {
  description = "The Routing configuration."
  value       = azurerm_vpn_gateway_connection.this.routing
}

output "vpn_gateway_connection_traffic_selector_policy" {
  description = "The Traffic Selector Policy configuration."
  value       = azurerm_vpn_gateway_connection.this.traffic_selector_policy
}
