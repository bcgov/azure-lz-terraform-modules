resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.private_dns_links

  name                  = each.value.name
  private_dns_zone_name = each.value.private_dns_zone.name
  resource_group_name   = each.value.private_dns_zone.resource_group_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = false
  tags                  = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}
