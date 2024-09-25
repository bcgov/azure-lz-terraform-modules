output "key_vault_certificate_name" {
  description = "The name of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.this.name  
}

output "key_vault_certificate_id" {
  description = "The ID of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.this.id
}

output "key_vault_certificate_thumbprint" {
  description = "The thumbprint of the Key Vault Certificate."
  value       = azurerm_key_vault_certificate.this.thumbprint
}

output "key_vault_secret_id" {
  description = "The ID of the Key Vault Secret."
  value       = azurerm_key_vault_certificate.this.secret_id  
  sensitive = true
}