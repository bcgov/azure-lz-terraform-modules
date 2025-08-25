output "vnet-links" {
  description = "A map of Private DNS Zone Virtual Network Link IDs created."
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.this : k => v.id }
}

# output "vnet_link_id" {
#   description = "The ID of the Private DNS Zone Virtual Network Link."
#   value       = azurerm_private_dns_zone_virtual_network_link.this.id
# }

# output "vnet_link_name" {
#   description = "The name of the Private DNS Zone Virtual Network Link."
#   value       = azurerm_private_dns_zone_virtual_network_link.this.name
# }

# output "vnet_link_registration_enabled" {
#   description = "Indicates whether auto-registration of virtual machine records in the virtual network in the Private DNS zone is enabled."
#   value       = azurerm_private_dns_zone_virtual_network_link.this.registration_enabled
# }

# output "vnet_link_resolution_policy" {
#   description = "The resolution policy of the Private DNS Zone Virtual Network Link."
#   value       = azurerm_private_dns_zone_virtual_network_link.this.resolution_policy
# }
