output "express_route_circuit_id" {
  description = "The ID of the ExpressRoute Circuit."
  value = {
    for key, id in azurerm_express_route_circuit.this : key => id.id
  }
}

output "service_provider_provisioning_state" {
  description = "The provisioning state of the ExpressRoute Circuit Service Provider."
  value = {
    for key, state in azurerm_express_route_circuit.this : key => state.service_provider_provisioning_state
  }
}

output "service_key" {
  description = "The service key of the ExpressRoute Circuit."
  value = {
    for key, service_key in azurerm_express_route_circuit.this : key => service_key.service_key
  }
  sensitive = true
}

output "express_route_circuit_peering_id" {
  description = "The ID of the ExpressRoute Circuit Peering."
  value = {
    for key, id in azurerm_express_route_circuit_peering.this : key => id.id
  }
}

output "express_route_connection_id" {
  description = "The ID of the ExpressRoute Connection."
  value       = azurerm_express_route_connection.this.id
}
