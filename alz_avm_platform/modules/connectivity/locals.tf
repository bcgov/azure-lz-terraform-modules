locals {
  private_dns_zone_resource_group_name = coalesce(
    var.private_dns_zone_resource_group_name,
    try(provider::azapi::parse_resource_id(
      "Microsoft.Resources/resourceGroups",
      values(var.virtual_hubs)[0].private_dns_zones.parent_id
    ).resource_group_name, null)
  )

  private_dns_resolver_enabled = anytrue([
    for hub in values(var.virtual_hubs) : try(hub.enabled_resources.private_dns_resolver, false) || try(hub.enabled_resources.sidecar_virtual_network, false)
  ])

  private_dns_resolver_resource_group_name = try(values(var.virtual_hubs)[0].private_dns_resolver.resource_group_name, null)

  firewall_policy_resource_group_name = values(var.virtual_hubs)[0].firewall_policy.resource_group_name
}

locals {
  # Sidecar virtual network subnets that host DNS resolver endpoints, flattened across hubs so each gets its own NSG.
  # Unused when the hub keeps the existing private DNS spoke instead of a virtual WAN sidecar.
  dns_resolver_endpoint_subnet_names = ["inbound_endpoint", "outbound_endpoint"]
  dns_resolver_endpoint_subnets = merge([
    for hub_key, hub in var.virtual_hubs : {
      for subnet_key, subnet in try(hub.sidecar_virtual_network.subnets, {}) : "${hub_key}-${subnet_key}" => {
        hub_key     = hub_key
        subnet_key  = subnet_key
        subnet_name = subnet.name
        location    = hub.location
      } if try(hub.enabled_resources.sidecar_virtual_network, false) && contains(local.dns_resolver_endpoint_subnet_names, subnet_key)
    }
  ]...)

  # Re-inject the NSGs created below into each subnet's network_security_group before passing virtual_hubs to the module.
  virtual_hubs_with_dns_resolver_nsgs = {
    for hub_key, hub in var.virtual_hubs : hub_key => try(hub.enabled_resources.sidecar_virtual_network, false) ? merge(hub, {
      sidecar_virtual_network = merge(hub.sidecar_virtual_network, {
        subnets = { for subnet_key, subnet in hub.sidecar_virtual_network.subnets : subnet_key => merge(subnet, {
          network_security_group = contains(keys(local.dns_resolver_endpoint_subnets), "${hub_key}-${subnet_key}") ? {
            id = azurerm_network_security_group.dns_resolver_endpoint["${hub_key}-${subnet_key}"].id
          } : try(subnet.network_security_group, null)
        }) }
      })
    }) : hub
  }
}
