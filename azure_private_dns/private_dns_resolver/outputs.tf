output "private_dns_resolver" {
  description = "The ID of the Private DNS Resolver."
  value       = azurerm_private_dns_resolver.this
}

output "private_dns_resolver_inbound_endpoint" {
  description = "The ID of the Private DNS Resolver Inbound Endpoint."
  value       = azurerm_private_dns_resolver_inbound_endpoint.this
}

output "private_dns_resolver_outbound_endpoint" {
  description = "The ID of the Private DNS Resolver Outbound Endpoint."
  value       = azurerm_private_dns_resolver_outbound_endpoint.this
}

output "private_dns_resolver_dns_forwarding_ruleset" {
  description = "The ID of the Private DNS Resolver DNS Forwarding Ruleset."
  value       = azurerm_private_dns_resolver_dns_forwarding_ruleset.this
}

output "private_dns_resolver_forwarding_rule-dmz_domain" {
  description = "The Private DNS Resolver Forwarding Rule."
  value       = azurerm_private_dns_resolver_forwarding_rule.dmz_domain
}

output "private_dns_resolver_forwarding_rule-bcgov_domain" {
  description = "The Private DNS Resolver Forwarding Rule."
  value       = azurerm_private_dns_resolver_forwarding_rule.bcgov_domain
}

output "private_dns_resolver_forwarding_rule-gov_domain" {
  description = "The Private DNS Resolver Forwarding Rule."
  value       = azurerm_private_dns_resolver_forwarding_rule.gov_domain
}
