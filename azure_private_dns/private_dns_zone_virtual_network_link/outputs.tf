output "vnet-links" {
  description = "A map of Private DNS Zone Virtual Network Link IDs created."
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.this : k => v.id }
}
