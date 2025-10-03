resource "azurerm_private_dns_resolver_forwarding_rule" "dmz_domain" {
  name                      = "dmz"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this.id
  domain_name               = "dmz."
  enabled                   = true

  target_dns_servers {
    ip_address = "142.34.50.52" # On-premises DNS server IP address
    port       = 53
  }

  target_dns_servers {
    ip_address = "142.34.208.8" # On-premises DNS server IP address
    port       = 53
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "bcgov_domain" {
  name                      = "bcgov"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this.id
  domain_name               = "bcgov."
  enabled                   = true

  target_dns_servers {
    ip_address = "142.34.50.52" # On-premises DNS server IP address
    port       = 53
  }

  target_dns_servers {
    ip_address = "142.34.208.8" # On-premises DNS server IP address
    port       = 53
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "gov_domain" {
  name                      = "gov"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this.id
  domain_name               = "gov."
  enabled                   = false

  target_dns_servers {
    ip_address = "142.34.50.52" # On-premises DNS server IP address
    port       = 53
  }

  target_dns_servers {
    ip_address = "142.34.208.8" # On-premises DNS server IP address
    port       = 53
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
