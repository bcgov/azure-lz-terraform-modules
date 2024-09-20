output "firewall_policy_id" {
  description = "The ID of the Firewall Policy."
  value       = azurerm_firewall_policy.this.id
}
