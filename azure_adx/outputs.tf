# ADX Cluster outputs
output "adx_cluster_uri" {
  description = "ADX cluster URL"
  value       = azurerm_kusto_cluster.adx.uri
}

output "adx_cluster_id" {
  description = "ADX cluster resource ID"
  value       = azurerm_kusto_cluster.adx.id
}

# ADX Database outputs
output "adx_database_id" {
  description = "ADX database resource ID"
  value       = azurerm_kusto_database.adx.id
}

# Event Hub outputs
output "eventhub_namespace_id" {
  description = "Event Hub Namespace resource ID"
  value       = azurerm_eventhub_namespace.adx.id
}

output "eventhub_id" {
  description = "Event Hub resource ID"
  value       = azurerm_eventhub.adx.id
}

output "advanced_hunting_endpoint" {
  description = "Endpoint for Advanced Hunting queries"
  value       = "${azurerm_kusto_cluster.adx.uri}/v1/rest/query"
}

output "data_retention_period" {
  description = "Configured data retention period in days"
  value       = var.mde_data_retention_days
}
