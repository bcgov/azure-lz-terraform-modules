# Output a copy of configure_management_resources for use
# by the core module instance

output "configuration" {
  description = "Configuration settings for the \"management\" resources."
  value       = local.configure_management_resources
}

output "log_analytics_workspace" {
  description = "The Azure Log Analytics Workspace object."
  value       = module.alz.azurerm_log_analytics_workspace.management
}
