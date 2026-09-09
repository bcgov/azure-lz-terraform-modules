resource "azurerm_private_dns_resolver_forwarding_rule" "this" {
  for_each = {
    for rule in var.forwarding_rules : rule.name => rule
  }

  name                      = each.value.name
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this.id
  domain_name               = each.value.domain_name
  enabled                   = each.value.enabled

  dynamic "target_dns_servers" {
    for_each = each.value.target_dns_servers
    content {
      ip_address = target_dns_servers.value.ip_address
      port       = target_dns_servers.value.port
    }
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
