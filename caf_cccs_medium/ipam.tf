
resource "azurerm_resource_group" "rg" {
  name     = "${var.root_id}-ipam"
  location = var.primary_location
}

resource "azurerm_network_manager" "nm" {
  name                = var.root_id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  scope {
    subscription_ids = ["/subscriptions/${var.subscription_id_management}"]
  }
}

resource "azurerm_network_manager_ipam_pool" "pool" {
  name               = var.root_id
  network_manager_id = azurerm_network_manager.nm.id
  location           = azurerm_resource_group.rg.location
  display_name       = var.root_id
  address_prefixes   = var.ipam_pool_cidr_addresses
}
