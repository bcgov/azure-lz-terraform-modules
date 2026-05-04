resource "azurerm_resource_group" "ghrunners" {
  name     = var.virtual_network_resource_group_name
  location = var.location
}
