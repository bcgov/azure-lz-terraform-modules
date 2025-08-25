resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.private_dns_zone_virtual_network_link

  name                  = each.value.private_dns_zone_vnet_link_name
  private_dns_zone_name = each.value.private_dns_zone_name
  resource_group_name   = each.value.resource_group_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  tags                  = each.value.tags

  # name                  = var.private_dns_zone_vnet_link_name
  # private_dns_zone_name = var.private_dns_zone_name
  # resource_group_name   = var.resource_group_name
  # virtual_network_id    = var.virtual_network_id
  # registration_enabled  = var.registration_enabled
  # resolution_policy     = var.resolution_policy
  # tags                  = var.tags
}
