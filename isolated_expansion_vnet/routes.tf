resource "azurerm_route_table" "this" {
  for_each = local.route_table_key != null ? toset([local.route_table_key]) : toset([])

  name                          = local.route_table_names[each.key]
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false
  tags                          = local.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

moved {
  from = azurerm_route_table.none[0]
  to   = azurerm_route_table.this["none"]
}

moved {
  from = azurerm_route_table.private_nat[0]
  to   = azurerm_route_table.this["private_nat"]
}

moved {
  from = azurerm_route_table.firewall[0]
  to   = azurerm_route_table.this["firewall"]
}

resource "azurerm_route" "none_blackhole" {
  count = local.none_enabled ? 1 : 0

  name                = "internet-blackhole"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.this["none"].name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "None"
}

resource "azurerm_route" "firewall" {
  for_each = local.firewall_enabled ? local.firewall_routes : {}

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this["firewall"].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_route" "private_nat" {
  for_each = local.private_nat_enabled ? local.private_nat_routes : {}

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this["private_nat"].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = local.associated_subnet_keys

  subnet_id      = local.subnet_ids[each.key]
  route_table_id = local.egress_route_table_id
}
