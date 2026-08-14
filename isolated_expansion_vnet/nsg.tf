resource "azurerm_network_security_group" "this" {
  for_each = local.created_nsgs

  name                = coalesce(each.value.nsg_name, "${local.virtual_network_name}-${coalesce(each.value.name, each.key)}")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.nsg_rules_map

  name                        = each.value.rule_name
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_key].name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  description                 = each.value.rule.description

  source_port_range       = each.value.rule.source_port_ranges == null ? coalesce(each.value.rule.source_port_range, "*") : null
  source_port_ranges      = each.value.rule.source_port_ranges
  destination_port_range  = each.value.rule.destination_port_ranges == null ? coalesce(each.value.rule.destination_port_range, "*") : null
  destination_port_ranges = each.value.rule.destination_port_ranges

  source_address_prefix        = each.value.rule.source_address_prefixes == null ? coalesce(each.value.rule.source_address_prefix, "*") : null
  source_address_prefixes      = each.value.rule.source_address_prefixes
  destination_address_prefix   = each.value.rule.destination_address_prefixes == null ? each.value.rule.destination_address_prefix : null
  destination_address_prefixes = each.value.rule.destination_address_prefixes
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.subnets_needing_nsg

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.create_nsg ? azurerm_network_security_group.this[each.key].id : each.value.nsg_id
}
