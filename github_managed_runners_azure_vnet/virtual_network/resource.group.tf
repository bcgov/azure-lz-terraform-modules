resource "azurerm_resource_group" "ghrunners" {
  provider = azurerm.connectivity

  name     = var.virtual_network_resource_group_name
  location = var.location
}
