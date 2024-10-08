output "express_route_circuit_peering_id" {
  description = "The ID of the ExpressRoute Circuit Peering."
  value = {
    for key, id in azurerm_express_route_circuit_peering.this : key => id.id
  }
}
