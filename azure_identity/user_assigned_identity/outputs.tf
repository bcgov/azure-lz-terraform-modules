output "user_assigned_identity_id" {
  description = "The ID of the User Assigned Identity."
  value       = azurerm_user_assigned_identity.this.id  
}

output "client_id" {
  description = "The Client ID of the Service Principal associated with this User Assigned Identity."
  value       = azurerm_user_assigned_identity.this.client_id  
}

output "principal_id" {
  description = "The Principal ID of the Service Principal associated with this User Assigned Identity."
  value       = azurerm_user_assigned_identity.this.principal_id    
}

output "tenant_id" {
  description = "The Tenant ID of the Service Principal associated with this User Assigned Identity."
  value       = azurerm_user_assigned_identity.this.tenant_id    
}