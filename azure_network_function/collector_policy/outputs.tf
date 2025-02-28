output "collector_policy_name" {
  description = "The name of the Network Function Collector Policy."
  value       = azurerm_network_function_collector_policy.this.name
}

output "collector_policy_id" {
  description = "The ID of the Network Function Collector Policy."
  value       = azurerm_network_function_collector_policy.this.id
}

output "traffic_collector_id" {
  description = "The ID of the Traffic Collector associated with the Network Function Collector Policy."
  value       = azurerm_network_function_collector_policy.this.traffic_collector_id
}

output "ipfx_emission" {
  description = "The Emission configuration of the Network Function Collector Policy."
  value       = azurerm_network_function_collector_policy.this.ipfx_emission
}

output "ipfx_ingestion" {
  description = "The Ingestion configuration of the Network Function Collector Policy."
  value       = azurerm_network_function_collector_policy.this.ipfx_ingestion
}

output "monitor_diagnostic_setting" {
  description = "The Diagnostic Setting for the Network Function Collector Policy."
  value       = azurerm_monitor_diagnostic_setting.this
}
