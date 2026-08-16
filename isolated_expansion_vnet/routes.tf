# Azure name stays `${vnet}-none` so none, private_nat, and firewall_snat
# update this table in place. Renaming it forces a new table, and Azure
# rejects deleting a table that caller-managed subnets still reference.
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

resource "azurerm_route" "default_internet" {
  count = local.expansion_route_table_enabled ? 1 : 0

  name                   = "internet-blackhole"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.expansion[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = local.default_internet_next_hop_type
  next_hop_in_ip_address = local.default_internet_next_hop_ip
}

resource "azurerm_route" "firewall" {
  for_each = local.firewall_table_routes

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.expansion[0].name
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
