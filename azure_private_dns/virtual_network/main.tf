resource "azurerm_resource_group" "this" {
  name     = var.private_dns_resource_group_name
  location = var.location
}
