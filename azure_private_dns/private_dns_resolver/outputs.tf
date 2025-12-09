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

output "private_dns_resolver_forwarding_rules" {
  description = "Map of Private DNS Resolver Forwarding Rules."
  value = {
    for k, v in azurerm_private_dns_resolver_forwarding_rule.this : k => {
      id                        = v.id
      name                      = v.name
      dns_forwarding_ruleset_id = v.dns_forwarding_ruleset_id
      domain_name               = v.domain_name
      enabled                   = v.enabled
      target_dns_servers        = v.target_dns_servers
    }
  }
}
