#------------------------------------------------------------------------------
# Azure Monitor Workspace (for Prometheus metrics integration with Grafana)
#------------------------------------------------------------------------------

resource "azurerm_monitor_workspace" "this" {
  name                = "amw-${local.resource_prefix}-${local.resource_suffix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Azure Managed Grafana
#------------------------------------------------------------------------------

resource "azurerm_dashboard_grafana" "this" {
  name                = "${local.grafana_name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = var.grafana_sku

  # Grafana version (12 is the latest supported for Standard SKU)
  grafana_major_version = 12

  # Security settings
  public_network_access_enabled     = var.grafana_public_network_access
  zone_redundancy_enabled           = var.grafana_zone_redundancy
  api_key_enabled                   = var.grafana_api_key_enabled
  deterministic_outbound_ip_enabled = var.grafana_deterministic_outbound_ip

  # Managed identity for accessing Azure Monitor, Log Analytics
  identity {
    type = "SystemAssigned"
  }

  # Azure Monitor Workspace integration (for Prometheus metrics)
  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.this.id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Grafana Diagnostic Settings
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "grafana" {
  name                       = "diag-${azurerm_dashboard_grafana.this.name}"
  target_resource_id         = azurerm_dashboard_grafana.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "GrafanaLoginEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

#------------------------------------------------------------------------------
# Grafana Data Source Configuration
# Note: Data sources are configured via Grafana API or provisioning
# The following resources set up the required permissions and connections
#------------------------------------------------------------------------------

# Prometheus data source requires network connectivity
# This is handled by the private endpoint and VNet integration

# Azure Monitor data source is automatically available with the managed identity
# and the role assignments in identity.tf

#------------------------------------------------------------------------------
# Grafana Dashboard Provisioning
# Note: Dashboards can be provisioned via:
# 1. Grafana API using the azurerm_dashboard_grafana resource
# 2. Terraform grafana provider
# 3. Manual import via Grafana UI
#
# Dashboard JSON files are stored in the dashboards/ directory
# and can be imported using the Grafana API or provisioning tools
#------------------------------------------------------------------------------
