resource "azurerm_express_route_circuit" "this" {
  for_each = { for circuit in var.express_route_circuit : circuit.express_route_circuit_name => circuit }

  name                = each.value.express_route_circuit_name
  resource_group_name = azurerm_resource_group.this.name
  location            = each.value.location

  sku {
    tier   = each.value.sku.tier
    family = each.value.sku.family
  }

  service_provider_name    = each.value.service_provider_name
  peering_location         = each.value.peering_location
  bandwidth_in_mbps        = each.value.bandwidth_in_mbps
  allow_classic_operations = each.value.allow_classic_operations

  express_route_port_id = each.value.express_route_port_id
  bandwidth_in_gbps     = each.value.bandwidth_in_gbps

  authorization_key = each.value.authorization_key
  tags              = var.tags
}
