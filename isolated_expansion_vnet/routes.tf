resource "azurerm_route_table" "expansion" {
  count = local.expansion_route_table_enabled ? 1 : 0

  name                          = "${local.virtual_network_name}-none"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = false
  tags                          = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

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

moved {
  from = azurerm_route_table.none[0]
  to   = azurerm_route_table.expansion[0]
}

moved {
  from = azurerm_route_table.this["none"]
  to   = azurerm_route_table.expansion[0]
}

moved {
  from = azurerm_route_table.this["firewall"]
  to   = azurerm_route_table.firewall[0]
}

resource "azurerm_route" "default_internet" {
  count = local.expansion_route_table_enabled ? 1 : 0

  name                   = "internet-blackhole"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.expansion[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = local.private_nat_internet_next_hop_type
  next_hop_in_ip_address = local.private_nat_internet_next_hop_ip
}

moved {
  from = azurerm_route.none_blackhole[0]
  to   = azurerm_route.default_internet[0]
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

resource "azurerm_route" "private_nat" {
  for_each = local.private_nat_enterprise_routes

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.expansion[0].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = local.associated_subnet_keys

  subnet_id      = local.subnet_ids[each.key]
  route_table_id = local.egress_route_table_id
}
