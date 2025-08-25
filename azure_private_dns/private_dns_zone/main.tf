resource "azurerm_private_dns_zone" "this" {
  for_each = var.private_dns_zones

  name                = each.value.private_dns_zone_name
  resource_group_name = each.value.resource_group_name
}
