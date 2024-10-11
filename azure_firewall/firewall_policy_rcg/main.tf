resource "azurerm_firewall_policy_rule_collection_group" "this" {
  for_each = var.firewall_policy_rule_collection_group != null ? {
    for group in var.firewall_policy_rule_collection_group : group.name => group
  } : {}

  name               = each.value.name
  firewall_policy_id = var.firewall_policy_id
  priority           = each.value.priority

  dynamic "application_rule_collection" {
    for_each = each.value.application_rule_collection != null ? {
      for application_rule_collection in each.value.application_rule_collection : application_rule_collection.name => application_rule_collection
    } : {}

    content {
      name     = application_rule_collection.value.name
      action   = application_rule_collection.value.action
      priority = application_rule_collection.value.priority

      dynamic "rule" {
        for_each = application_rule_collection.value.rule

        content {
          name        = rule.value.name
          description = lookup(rule.value, "description", null)

          dynamic "protocols" {
            for_each = rule.value.protocols

            content {
              type = lookup(protocols.value, "type", "Https")
              port = lookup(protocols.value, "port", 0)
            }
          }

          dynamic "http_headers" {
            for_each = rule.value.http_headers != null ? [rule.value.http_headers] : []

            content {
              name  = lookup(http_headers.value, "name", null)
              value = lookup(http_headers.value, "value", null)
            }
          }

          source_addresses      = lookup(rule.value, "source_addresses", null)
          source_ip_groups      = lookup(rule.value, "source_ip_groups", null)
          destination_addresses = lookup(rule.value, "destination_addresses", null)
          destination_urls      = lookup(rule.value, "destination_urls", null)
          destination_fqdns     = lookup(rule.value, "destination_fqdns", null)
          destination_fqdn_tags = lookup(rule.value, "destination_fqdn_tags", null)
          terminate_tls         = lookup(rule.value, "terminate_tls", null)
          web_categories        = lookup(rule.value, "web_categories", null)
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = each.value.network_rule_collection != null ? {
      for network_rule_collection in each.value.network_rule_collection : network_rule_collection.name => network_rule_collection
    } : {}

    content {
      name     = lookup(network_rule_collection.value, "name")
      action   = lookup(network_rule_collection.value, "action", "Deny")
      priority = lookup(network_rule_collection.value, "priority", 100)

      dynamic "rule" {
        for_each = network_rule_collection.value.rule

        content {
          name                  = lookup(rule.value, "name")
          description           = lookup(rule.value, "description", null)
          protocols             = lookup(rule.value, "protocols", ["Any"])
          destination_ports     = lookup(rule.value, "destination_ports", ["*"])
          source_addresses      = lookup(rule.value, "source_addresses", [])
          source_ip_groups      = lookup(rule.value, "source_ip_groups", [])
          destination_addresses = lookup(rule.value, "destination_addresses", [])
          destination_ip_groups = lookup(rule.value, "destination_ip_groups", [])
          destination_fqdns     = lookup(rule.value, "destination_fqdns", [])
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = each.value.nat_rule_collection != null ? {
      for nat_rule_collection in each.value.nat_rule_collection : nat_rule_collection.name => nat_rule_collection
    } : {}

    content {
      name     = nat_rule_collection.value.name
      action   = nat_rule_collection.value.action
      priority = nat_rule_collection.value.priority

      rule {
        name                = nat_rule_collection.value.rule.name
        description         = nat_rule_collection.value.rule.description
        protocols           = nat_rule_collection.value.rule.protocols
        source_addresses    = nat_rule_collection.value.rule.source_addresses
        source_ip_groups    = nat_rule_collection.value.rule.source_ip_groups
        destination_address = nat_rule_collection.value.rule.destination_address
        destination_ports   = nat_rule_collection.value.rule.destination_ports
        translated_address  = nat_rule_collection.value.rule.translated_address
        translated_fqdn     = nat_rule_collection.value.rule.translated_fqdn
        translated_port     = nat_rule_collection.value.rule.translated_port
      }
    }
  }
}
