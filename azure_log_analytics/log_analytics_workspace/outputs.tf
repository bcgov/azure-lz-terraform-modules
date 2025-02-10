output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.name
}

output "log_analytics_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.id
}

output "log_analytics_workspace_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.workspace_id
}

output "log_analytics_sku" {
  description = "The SKU of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.sku
}

output "log_analytics_retention_in_days" {
  description = "The retention in days of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.retention_in_days
}

output "log_analytics_daily_quota_gb" {
  description = "The daily quota in GB of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.daily_quota_gb
}

output "log_analytics_reservation_capacity_in_gb_per_day" {
  description = "The reservation capacity in GB per day of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.law.reservation_capacity_in_gb_per_day
}
