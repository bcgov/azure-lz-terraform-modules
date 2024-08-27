resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = "${var.private_dns_resolver_name}-inbound-endpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = azurerm_private_dns_resolver.this.location

  ip_configurations {
    subnet_id                    = local.subnets["inbound_endpoint"].id
    private_ip_address           = local.subnets["inbound_endpoint"].first_available_ip
    private_ip_allocation_method = "Static"
  }
}
