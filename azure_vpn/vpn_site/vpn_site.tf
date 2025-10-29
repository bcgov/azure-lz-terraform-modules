resource "azurerm_vpn_site" "this" {
  for_each = { for site in var.vpn_site : site.name => site }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  virtual_wan_id      = each.value.virtual_wan_id

  dynamic "link" {
    for_each = each.value.link != null ? each.value.link : []

    content {
      name          = link.value.name
      fqdn          = link.value.fqdn
      ip_address    = link.value.ip_address
      provider_name = link.value.provider_name
      speed_in_mbps = link.value.speed_in_mbps

      dynamic "bgp" {
        for_each = link.value.bgp != null ? [link.value.bgp] : []

        content {
          asn             = bgp.value.asn
          peering_address = bgp.value.peering_address
        }
      }
    }
  }

  address_cidrs = each.value.address_cidrs
  device_model  = each.value.device_model
  device_vendor = each.value.device_vendor

  dynamic "o365_policy" {
    for_each = each.value.o365_policy != null ? [each.value.o365_policy] : []

    content {
      dynamic "traffic_category" {
        for_each = o365_policy.value.traffic_category != null ? [o365_policy.value.traffic_category] : []

        content {
          allow_endpoint_enabled    = traffic_category.value.allow_endpoint_enabled
          default_endpoint_enabled  = traffic_category.value.default_endpoint_enabled
          optimize_endpoint_enabled = traffic_category.value.optimize_endpoint_enabled
        }
      }
    }
  }

  tags = each.value.tags
}
