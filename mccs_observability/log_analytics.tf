#------------------------------------------------------------------------------
# Log Analytics Workspace
#------------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days

  # Note: For full private link setup, a private endpoint should be created
  # and linked via azure_private_dns module. For now, allow Azure services
  # to ingest logs via public endpoint (still secured by Azure RBAC).
  internet_ingestion_enabled = true
  internet_query_enabled     = false

  tags = local.tags
}

#------------------------------------------------------------------------------
# Log Analytics Solutions (optional)
#------------------------------------------------------------------------------

# Container Insights solution for ACI monitoring
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = azurerm_resource_group.this.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

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
