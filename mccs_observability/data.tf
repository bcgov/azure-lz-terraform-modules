data "azurerm_client_config" "current" {}

# Reference existing ExpressRoute circuits for diagnostic settings
data "azurerm_express_route_circuit" "circuits" {
  for_each = var.expressroute_circuits

  name                = each.value.circuit_name
  resource_group_name = each.value.resource_group_name
}

# Reference existing ExpressRoute gateways for diagnostic settings
data "azurerm_virtual_network_gateway" "gateways" {
  for_each = var.expressroute_gateways

  name                = each.value.gateway_name
  resource_group_name = each.value.resource_group_name
}
