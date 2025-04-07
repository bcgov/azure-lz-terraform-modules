# Get the current client configuration from the AzureRM provider
data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "vnet" {
  name                = var.existing_virtual_network_name
  resource_group_name = var.existing_virtual_network_resource_group_name
}
