resource "azurerm_private_dns_resolver" "this" {
  name                = var.private_dns_resolver_name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.virtual_network_object.id
}
