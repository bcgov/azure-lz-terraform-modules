resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "additional" {
  for_each = var.additional_forwarding_rulesets

  name                = "${var.private_dns_resolver_name}-${each.key}"
  resource_group_name = var.resource_group_name
  location            = var.location
  private_dns_resolver_outbound_endpoint_ids = [
    azurerm_private_dns_resolver_outbound_endpoint.this.id
  ]

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "additional" {
  for_each = local.additional_forwarding_rules

  name                      = each.value.rule.name
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.additional[each.value.ruleset_key].id
  domain_name               = each.value.rule.domain_name
  enabled                   = each.value.rule.enabled

  dynamic "target_dns_servers" {
    for_each = each.value.rule.target_dns_servers
    content {
      ip_address = target_dns_servers.value.ip_address
      port       = coalesce(target_dns_servers.value.port, 53)
    }
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
