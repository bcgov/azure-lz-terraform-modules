output "management_group_id" {
  value       = azurerm_management_group.project_set.id
  description = "The management group ID for the project set."
}

output "subscription_ids" {
  value       = { for k, v in module.lz_vending : k => v.subscription_id }
  description = "The subscription IDs of each landing zone created."
}
