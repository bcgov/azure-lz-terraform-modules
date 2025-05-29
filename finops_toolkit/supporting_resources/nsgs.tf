resource "azurerm_network_security_group" "powerbi_data_gateway" {
  name                = var.data_gateway_subnet_name
  location            = var.location
  resource_group_name = var.existing_virtual_network_resource_group_name

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
