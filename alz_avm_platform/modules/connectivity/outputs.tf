output "avm-ptn-alz-connectivity-virtual-wan" {
  value = module.avm-ptn-alz-connectivity-virtual-wan
}

output "firewall_policy_resource_ids" {
  description = "The resource IDs of the firewall policies managed by the AVM connectivity module."
  value       = module.avm-ptn-alz-connectivity-virtual-wan.firewall_policy_resource_ids
}

output "network_manager_ipam_pool_name" {
  description = "The name of the Network Manager IPAM Pool."
  value       = azurerm_network_manager_ipam_pool.this.name
}

output "network_manager_ipam_pool_id" {
  description = "The ID of the Network Manager IPAM Pool."
  value       = azurerm_network_manager_ipam_pool.this.id
}

output "network_manager_ipam_pool_address_prefixes" {
  description = "The address prefixes of the Network Manager IPAM Pool."
  value       = azurerm_network_manager_ipam_pool.this.address_prefixes
}
