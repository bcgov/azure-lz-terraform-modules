resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.private_dns_zone_virtual_network_link

  name                  = each.value.private_dns_zone_vnet_link_name
  private_dns_zone_name = each.value.private_dns_zone_name
  resource_group_name   = each.value.resource_group_name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  # resolution_policy     = each.value.resolution_policy # This property is only supported in AzureRM v4.35.0 and later (but our use of the CAF has not been updated to v4 yet)
  tags = each.value.tags
}
