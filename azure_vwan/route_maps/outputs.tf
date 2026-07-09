output "route_map_ids" {
  description = "Map of route map Terraform keys to Azure resource IDs."
  value       = { for key, route_map in azurerm_route_map.this : key => route_map.id }
}

output "route_maps" {
  description = "Full azurerm_route_map resources keyed by Terraform map key."
  value       = azurerm_route_map.this
}
