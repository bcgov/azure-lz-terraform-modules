output "private_dns_resolver_cidr" {
  description = "The CIDR block of the Private DNS Resolver"
  value       = azurerm_network_manager_ipam_pool_static_cidr.private_dns_resolver.address_prefixes[0]
}

output "virtual_network" {
  description = "The Private DNS Resolver virtual network object"
  value       = azurerm_virtual_network.this
}

output "virtual_network_id" {
  description = "The Private DNS Resolver virtual network ID"
  value       = azurerm_virtual_network.this.id
}

output "virtual_hub_connection" {
  description = "The Private DNS Resolver virtual hub connection object"
  value       = azurerm_virtual_hub_connection.this
}

output "resource_group_name" {
  description = "The Private DNS Resolver resource group name"
  value       = azurerm_resource_group.this.name
}
