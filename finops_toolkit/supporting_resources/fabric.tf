resource "azurerm_fabric_capacity" "this" {
  name                = lower(var.fabric_capacity_name)
  resource_group_name = var.existing_resource_group_name
  location            = var.location

  administration_members = var.administration_members

  sku {
    name = var.sku
    tier = "Fabric"
  }

  tags = var.tags
}
