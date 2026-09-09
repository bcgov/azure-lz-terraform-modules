module "route_maps" {
  source = "../route_maps"

  subscription_id_connectivity = var.subscription_id_connectivity
  virtual_hub_id               = var.virtual_hub_id
  route_maps                   = local.route_maps
}

# Patch routingConfiguration on existing VPN connections.
# azapi_update_resource does not revert properties when removed from config.
resource "azapi_update_resource" "vpn_connection_routing" {
  for_each = var.vpn_connection_routing

  type = "Microsoft.Network/vpnGateways/vpnConnections@2024-05-01"
  name = each.value.vpn_connection_name
  parent_id = format(
    "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/vpnGateways/%s",
    var.subscription_id_connectivity,
    var.virtual_hub_resource_group_name,
    each.value.vpn_gateway_name,
  )

  body = {
    properties = {
      routingConfiguration = local.connection_routing
    }
  }

  depends_on = [module.route_maps]
}

# Patch routingConfiguration on existing ExpressRoute connections.
resource "azapi_update_resource" "express_route_connection_routing" {
  for_each = var.express_route_connection_routing

  type = "Microsoft.Network/expressRouteGateways/expressRouteConnections@2024-05-01"
  name = each.value.express_route_connection_name
  parent_id = format(
    "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/expressRouteGateways/%s",
    var.subscription_id_connectivity,
    var.virtual_hub_resource_group_name,
    each.value.express_route_gateway_name,
  )

  body = {
    properties = {
      routingConfiguration = local.connection_routing
    }
  }

  depends_on = [module.route_maps]
}
