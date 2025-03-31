resource "azurerm_private_dns_resolver_outbound_endpoint" "this" {
  name                    = "${var.private_dns_resolver_name}-outbound-endpoint"
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = azurerm_private_dns_resolver.this.location

  subnet_id = local.subnets["outbound_endpoint"].id

  tags = {}

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
