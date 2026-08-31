resource "azurerm_resource_group" "this" {
  name     = var.vwan_resource_group_name
  location = var.location

  provider = azurerm.connectivity
}

module "avm-ptn-alz-connectivity-virtual-wan" {
  source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm"
  version = "0.17.1"

  depends_on = [azurerm_resource_group.this]

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi.connectivity
  }

  default_naming_convention          = var.default_naming_convention
  default_naming_convention_sequence = var.default_naming_convention_sequence
  route_maps                         = var.route_maps
  tags                               = var.tags
  virtual_hubs                       = var.virtual_hubs
  virtual_wan_settings               = var.virtual_wan_settings
}
