output "express_route_circuit_id" {
  description = "The ID of the ExpressRoute Circuit."
  value       = azurerm_express_route_circuit.circuit.id
}

output "service_provider_provisioning_state" {
  description = "The provisioning state of the ExpressRoute Circuit Service Provider."
  value       = azurerm_express_route_circuit.circuit.service_provider_provisioning_state
}

output "service_key" {
  description = "The service key of the ExpressRoute Circuit."
  value       = azurerm_express_route_circuit.circuit.service_key
}