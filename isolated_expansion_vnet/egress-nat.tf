resource "azurerm_public_ip" "nat" {
  count = local.nat_enabled ? local.nat.public_ip_count : 0

  name                = "${local.virtual_network_name}-nat-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = local.nat.zones
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_nat_gateway" "this" {
  count = local.nat_enabled ? 1 : 0

  name                    = "${local.virtual_network_name}-nat"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = local.nat.sku_name
  idle_timeout_in_minutes = local.nat.idle_timeout
  zones                   = local.nat.zones
  tags                    = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = local.nat_enabled ? local.nat.public_ip_count : 0

  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[count.index].id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = local.nat_enabled ? {
    for key, subnet in var.subnets : key => subnet if subnet.associate_nat_gateway
  } : {}

  subnet_id      = azurerm_subnet.this[each.key].id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}
