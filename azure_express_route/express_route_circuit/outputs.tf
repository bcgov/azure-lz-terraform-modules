output "resource_group_name" {
  description = "The name of the Resource Group."
  value       = azurerm_resource_group.this.name
}

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
