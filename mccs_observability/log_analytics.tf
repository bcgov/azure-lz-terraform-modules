#------------------------------------------------------------------------------
# Log Analytics Workspace
#------------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days

  # Ingestion and query are allowed over the public endpoints and secured by
  # Azure RBAC. Grafana queries the workspace via the public api.loganalytics.io
  # endpoint, so internet_query_enabled must stay true until the workspace is
  # fronted by a private endpoint.
  internet_ingestion_enabled = true
  internet_query_enabled     = true

  tags = local.tags
}

#------------------------------------------------------------------------------
# Diagnostic Settings for Log Analytics Workspace itself
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "log_analytics" {
  name                       = "diag-${local.log_analytics_workspace_name}"
  target_resource_id         = azurerm_log_analytics_workspace.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "Audit"
  }

  enabled_log {
    category = "SummaryLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
