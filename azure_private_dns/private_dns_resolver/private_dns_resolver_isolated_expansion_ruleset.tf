# Isolated expansion VNets are not vWAN spokes and cannot reach this inbound
# or the hub firewall DNS proxy in none/nat. Azure-provided DNS plus a
# ruleset VNet link (created by isolated_expansion_vnet) forwards here.
# Azure skips '.' for reserved PaaS suffixes, so those get explicit rules.
# Zone links stay on this resolver VNet only. Do not link this ruleset to
# this VNet or to enterprise-routed spokes.

locals {
  isolated_expansion_forwarding_ruleset_enabled = var.isolated_expansion_forwarding_ruleset.enabled
  isolated_expansion_forwarding_ruleset_name = coalesce(
    var.isolated_expansion_forwarding_ruleset.name,
    "${var.private_dns_resolver_name}-isolated-expansion"
  )
  isolated_expansion_inbound_ip = one(azurerm_private_dns_resolver_inbound_endpoint.this.ip_configurations).private_ip_address
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "isolated_expansion" {
  count = local.isolated_expansion_forwarding_ruleset_enabled ? 1 : 0

  name                = local.isolated_expansion_forwarding_ruleset_name
  resource_group_name = var.resource_group_name
  location            = var.location
  private_dns_resolver_outbound_endpoint_ids = [
    azurerm_private_dns_resolver_outbound_endpoint.this.id
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "isolated_expansion_all" {
  count = local.isolated_expansion_forwarding_ruleset_enabled ? 1 : 0

  name                      = "all-to-inbound"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.isolated_expansion[0].id
  domain_name               = "."
  enabled                   = true

  target_dns_servers {
    ip_address = local.isolated_expansion_inbound_ip
    port       = 53
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "isolated_expansion_reserved" {
  for_each = local.isolated_expansion_forwarding_ruleset_enabled ? local.isolated_expansion_explicit_rules : {}

  name                      = each.key
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.isolated_expansion[0].id
  domain_name               = each.value
  enabled                   = true

  target_dns_servers {
    ip_address = local.isolated_expansion_inbound_ip
    port       = 53
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}
