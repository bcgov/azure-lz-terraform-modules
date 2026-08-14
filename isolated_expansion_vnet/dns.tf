data "azapi_resource_list" "central_private_dns_zones" {
  count = var.private_dns_zone_resource_group_id != null ? 1 : 0

  type      = "Microsoft.Network/privateDnsZones@2020-06-01"
  parent_id = var.private_dns_zone_resource_group_id
  response_export_values = {
    ids = "value[].id"
  }
}

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
