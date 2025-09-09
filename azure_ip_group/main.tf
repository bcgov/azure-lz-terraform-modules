resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_ip_group" "ipgroup" {
  for_each = { for ipg in var.ip_group : ipg.name => ipg }

  name                = each.value.name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  cidrs = each.value.ip_addresses
}
