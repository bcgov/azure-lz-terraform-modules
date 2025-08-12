output "routing_intent_and_policies_routes" {
  value = azapi_update_resource.vwan_routing_intent_and_policies.output.properties.routes
}
