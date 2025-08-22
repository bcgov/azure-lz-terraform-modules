# output "private_dns_zone_id" {
#   description = "The ID of the Private DNS Zone"
#   value       = azurerm_private_dns_zone.this.id
# }

output "private_dns_zone_ids" {
  description = "A map of Private DNS Zone IDs keyed by zone name."
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}
