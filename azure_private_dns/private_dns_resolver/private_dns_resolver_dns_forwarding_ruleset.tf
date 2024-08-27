resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "this" {
  name                = "${var.private_dns_resolver_name}-dns-forwarding-ruleset"
  resource_group_name = var.resource_group_name
  location            = var.location
  private_dns_resolver_outbound_endpoint_ids = [
    azurerm_private_dns_resolver_outbound_endpoint.this.id
  ]
}
