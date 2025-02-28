output "resource_group_name" {
  description = "The name of the Resource Group in which the Network Function Azure Traffic Collector is created."
  value       = azurerm_resource_group.this.name
}

output "resource_group_id" {
  description = "The ID of the Resource Group in which the Network Function Azure Traffic Collector is created."
  value       = azurerm_resource_group.this.id
}

output "collector_name" {
  description = "The name of the Network Function Azure Traffic Collector."
  value       = azurerm_network_function_azure_traffic_collector.this.name
}

output "collector_id" {
  description = "The ID of the Network Function Azure Traffic Collector."
  value       = azurerm_network_function_azure_traffic_collector.this.id
}

output "collector_policy_ids" {
  description = "The IDs of the Network Function Azure Traffic Collector Policies associated with this Network Function Azure Traffic Collector."
  value       = azurerm_network_function_azure_traffic_collector.this.collector_policy_ids
}

output "collector_virtual_hub_id" {
  description = "The ID of the Virtual Hub associated with this Network Function Azure Traffic Collector."
  value       = azurerm_network_function_azure_traffic_collector.this.virtual_hub_id
}
