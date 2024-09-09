output "express_route_circuit_id" {
  description = "The ID of the ExpressRoute Circuit."
  value       = module.express_route_circuit.express_route_circuit_id
}

output "service_provider_provisioning_state" {
  description = "The provisioning state of the ExpressRoute Circuit Service Provider."
  value       = module.express_route_circuit.service_provider_provisioning_state
}

output "service_key" {
  description = "The service key of the ExpressRoute Circuit."
  value       = module.express_route_circuit.service_key
  sensitive   = true
}

output "circuit_peering_id" {
  description = "The ID of the ExpressRoute Circuit Peering."
  value       = module.express_route_peering.express_route_circuit_peering_id
}

output "connection_id" {
  description = "The ID of the ExpressRoute Connection."
  value       = module.express_route_connection.express_route_connection_id
}
