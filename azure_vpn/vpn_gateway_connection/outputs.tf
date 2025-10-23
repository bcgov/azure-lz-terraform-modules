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

# output "vpn_gateway_connection_id" {
#   description = "The ID of the VPN Gateway Connection."
#   value       = azurerm_vpn_gateway_connection.this.id
# }

# output "vpn_gateway_connection_name" {
#   description = "The name of the VPN Gateway Connection."
#   value       = azurerm_vpn_gateway_connection.this.name
# }

# output "vpn_gateway_connection_remote_vpn_site_id" {
#   description = "The ID of the Remote VPN Site."
#   value       = azurerm_vpn_gateway_connection.this.remote_vpn_site_id
# }

# output "vpn_gateway_connection_vpn_gateway_id" {
#   description = "The ID of the VPN Gateway."
#   value       = azurerm_vpn_gateway_connection.this.vpn_gateway_id
# }

# output "vpn_gateway_connection_vpn_link" {
#   description = "The VPN Link configuration."
#   value       = azurerm_vpn_gateway_connection.this.vpn_link
# }

# output "vpn_gateway_connection_internet_security_enabled" {
#   description = "Is Internet Security enabled for the VPN Gateway Connection."
#   value       = azurerm_vpn_gateway_connection.this.internet_security_enabled
# }

# output "vpn_gateway_connection_routing" {
#   description = "The Routing configuration."
#   value       = azurerm_vpn_gateway_connection.this.routing
# }

# output "vpn_gateway_connection_traffic_selector_policy" {
#   description = "The Traffic Selector Policy configuration."
#   value       = azurerm_vpn_gateway_connection.this.traffic_selector_policy
# }
