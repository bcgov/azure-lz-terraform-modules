output "identity_id" {
  description = "The ID of the User Assigned Identity."
  value       = module.base_firewall_policy_managed_identity.user_assigned_identity_id
}

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = module.base_firewall_policy_key_vault.key_vault_id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = module.base_firewall_policy_key_vault.key_vault_uri
}

output "firewall_policy_id" {
  description = "The Azure Firewall Policy ID."
  value       = azurerm_firewall_policy.base_firewall_policy.id
}

output "base_firewall_policy" {
  description = "The base Azure Firewall Policy object."
  value       = azurerm_firewall_policy.base_firewall_policy
}

output "lz_firewall_policy" {
  description = "The base Azure Firewall Policy object."
  value       = module.lz_firewall_policy
}
