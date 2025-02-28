resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_network_function_azure_traffic_collector" "this" {
  name                = var.collector_name
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  tags = var.tags
}
