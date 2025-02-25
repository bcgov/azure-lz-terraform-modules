resource "azurerm_resource_group" "alerts_logic_app" {
  name     = var.resource_group_name
  location = var.location
}
