resource "azurerm_route_table" "firewall" {
  count = local.firewall_enabled ? 1 : 0

  name                          = "${local.virtual_network_name}-fw"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false
  tags                          = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_route" "firewall" {
  for_each = local.firewall_enabled ? local.firewall_routes : {}

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.firewall[0].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}
