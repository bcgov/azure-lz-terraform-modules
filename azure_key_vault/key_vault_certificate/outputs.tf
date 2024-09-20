output "key_vault_certificate_id" {
  description = "The ID of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.this.id
}

output "key_vault_certificate_thumbprint" {
  description = "The thumbprint of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.this.thumbprint
}
