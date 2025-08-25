output "private_dns_zone_ids" {
  description = "A map of Private DNS Zone IDs keyed by zone name."
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}
