locals {
  subscription_id_connectivity = coalesce(var.subscription_id_connectivity, local.subscription_id_management)
  subscription_id_management   = coalesce(var.subscription_id_management, data.azurerm_client_config.current.subscription_id)

  express_route_circuit_peering_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/expressRouteCircuits/%s/peerings/%s",
    local.subscription_id_connectivity, var.express_route_circuit_resource_group_name, var.express_route_circuit_name, var.circuit_peering_type
  )

  express_route_gateway_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/expressRouteGateways/%s",
    local.subscription_id_connectivity, var.express_route_gateway_resource_group_name, var.express_route_gateway_name
  )
}
