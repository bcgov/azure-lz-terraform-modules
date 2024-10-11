output "firewall_policy_rule_collection_group" {
  value = {
    for idx, group in azurerm_firewall_policy_rule_collection_group.this : idx => {
      name     = group.name
      priority = group.priority

      application_rule_collection = [
        for arc in group.application_rule_collection : {
          name     = arc.name
          action   = arc.action
          priority = arc.priority

          rule = [
            for r in arc.rule : {
              name                  = r.name
              description           = r.description
              protocols             = r.protocols
              http_headers          = r.http_headers
              source_addresses      = r.source_addresses
              source_ip_groups      = r.source_ip_groups
              destination_addresses = r.destination_addresses
              destination_urls      = r.destination_urls
              destination_fqdns     = r.destination_fqdns
              destination_fqdn_tags = r.destination_fqdn_tags
              terminate_tls         = r.terminate_tls
              web_categories        = r.web_categories
            }
          ]
        }
      ]

      network_rule_collection = [
        for nrc in group.network_rule_collection : {
          name     = nrc.name
          action   = nrc.action
          priority = nrc.priority

          rule = [
            for r in nrc.rule : {
              name                  = r.name
              description           = r.description
              protocols             = r.protocols
              destination_ports     = r.destination_ports
              source_addresses      = r.source_addresses
              source_ip_groups      = r.source_ip_groups
              destination_addresses = r.destination_addresses
              destination_ip_groups = r.destination_ip_groups
              destination_fqdns     = r.destination_fqdns
            }
          ]
        }
      ]
    }
  }
}
