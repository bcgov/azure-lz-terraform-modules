resource "azurerm_resource_group" "this" {
  provider = azurerm.management

  name     = var.ipam_pool_resource_group_name
  location = var.location
}

resource "azurerm_network_manager" "this" {
  provider = azurerm.management

  name                = var.network_manager_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  scope {
    management_group_ids = var.scope.management_group_ids
    subscription_ids     = var.scope.subscription_ids
  }
  scope_accesses = var.scope_accesses
  tags           = var.tags
}

resource "azurerm_network_manager_ipam_pool" "this" {
  provider = azurerm.management

  name               = var.ipam_pool_name
  location           = var.location
  network_manager_id = azurerm_network_manager.this.id
  address_prefixes   = var.ipam_pool_address_prefixes

  display_name     = var.ipam_pool_display_name
  description      = var.ipam_pool_description
  parent_pool_name = var.parent_pool_name
  tags             = var.tags
}
