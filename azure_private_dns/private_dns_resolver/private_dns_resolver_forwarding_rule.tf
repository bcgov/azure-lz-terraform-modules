resource "azurerm_private_dns_resolver_forwarding_rule" "this" {
  name                      = "privatedns-rule"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.this.id
  domain_name               = "gov.bc.ca."
  enabled                   = true

  target_dns_servers {
    ip_address = "142.34.50.52" # On-premises DNS server IP address
    port       = 53
  }

  target_dns_servers {
    ip_address = "142.34.208.8" # On-premises DNS server IP address
    port       = 53
  }

  metadata = {}
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
