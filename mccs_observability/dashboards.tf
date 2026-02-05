#------------------------------------------------------------------------------
# Grafana Provider Configuration
# Uses the Azure Managed Grafana endpoint with service principal authentication
#------------------------------------------------------------------------------

provider "grafana" {
  url  = azurerm_dashboard_grafana.this.endpoint
  auth = var.grafana_service_account_token

  # Use cloud provider authentication for Azure Managed Grafana
  # The Grafana managed identity has the necessary permissions
}

#------------------------------------------------------------------------------
# Grafana Folder for MCCS Dashboards
#------------------------------------------------------------------------------

resource "grafana_folder" "mccs" {
  count = var.enable_grafana_dashboards ? 1 : 0

  title = "MCCS Observability"
  uid   = "mccs-observability"
}

#------------------------------------------------------------------------------
# Dashboard: MCCS Overview
# Consolidated view of all ExpressRoute and Direct Connect circuits
#------------------------------------------------------------------------------

resource "grafana_dashboard" "mccs_overview" {
  count = var.enable_grafana_dashboards ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/mccs_overview.json", {
    # Template variables can be injected here if needed
  })
}

#------------------------------------------------------------------------------
# Dashboard: ExpressRoute Health
# Detailed health metrics for Azure ExpressRoute circuits
#------------------------------------------------------------------------------

resource "grafana_dashboard" "expressroute_health" {
  count = var.enable_grafana_dashboards ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/expressroute_health.json", {
    # Template variables can be injected here if needed
  })
}

#------------------------------------------------------------------------------
# Dashboard: Circuit Inventory
# Network documentation from Netbox
#------------------------------------------------------------------------------

resource "grafana_dashboard" "circuit_inventory" {
  count = var.enable_grafana_dashboards ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/circuit_inventory.json", {
    # Template variables can be injected here if needed
  })
}

#------------------------------------------------------------------------------
# Grafana Data Source: Azure Monitor
# Automatically configured with the Grafana managed identity
#------------------------------------------------------------------------------

resource "grafana_data_source" "azure_monitor" {
  count = var.enable_grafana_dashboards ? 1 : 0

  name = "Azure Monitor"
  type = "grafana-azure-monitor-datasource"

  json_data_encoded = jsonencode({
    cloudName               = "azuremonitor"
    subscriptionId          = local.subscription_id_connectivity
    azureAuthType           = "msi"
    tenantId                = data.azurerm_client_config.current.tenant_id
    clientId                = azurerm_dashboard_grafana.this.identity[0].principal_id
    azureLogAnalyticsSameAs = true
  })

  # Default data source for Azure Monitor queries
  is_default = true
}

#------------------------------------------------------------------------------
# Grafana Data Source: Log Analytics
# For querying diagnostic logs via KQL
#------------------------------------------------------------------------------

resource "grafana_data_source" "log_analytics" {
  count = var.enable_grafana_dashboards ? 1 : 0

  name = "Log Analytics - MCCS"
  type = "grafana-azure-monitor-datasource"

  json_data_encoded = jsonencode({
    cloudName                    = "azuremonitor"
    subscriptionId               = local.subscription_id_connectivity
    azureAuthType                = "msi"
    tenantId                     = data.azurerm_client_config.current.tenant_id
    clientId                     = azurerm_dashboard_grafana.this.identity[0].principal_id
    logAnalyticsDefaultWorkspace = azurerm_log_analytics_workspace.this.id
    azureLogAnalyticsSameAs      = false
  })
}

#------------------------------------------------------------------------------
# Grafana Data Source: Prometheus
# For custom metrics from Netbox exporter and future AWS integration
#------------------------------------------------------------------------------

resource "grafana_data_source" "prometheus" {
  count = var.enable_grafana_dashboards ? 1 : 0

  name = "Prometheus - MCCS"
  type = "prometheus"

  url = "http://${azurerm_container_group.prometheus.ip_address}:9090"

  json_data_encoded = jsonencode({
    httpMethod        = "POST"
    timeInterval      = "30s"
    queryTimeout      = "60s"
    manageAlerts      = false
    prometheusType    = "Prometheus"
    prometheusVersion = "2.48.0"
  })
}

#------------------------------------------------------------------------------
# Grafana Service Account for Terraform Management
# Note: This is created once and the token should be stored securely
#------------------------------------------------------------------------------

resource "grafana_service_account" "terraform" {
  count = var.enable_grafana_dashboards && var.create_grafana_service_account ? 1 : 0

  name        = "terraform-automation"
  role        = "Admin"
  is_disabled = false
}

resource "grafana_service_account_token" "terraform" {
  count = var.enable_grafana_dashboards && var.create_grafana_service_account ? 1 : 0

  name               = "terraform-token"
  service_account_id = grafana_service_account.terraform[0].id

  # Token expires in 1 year - should be rotated
  seconds_to_live = 31536000
}

# Store the service account token in Key Vault for future use
resource "azurerm_key_vault_secret" "grafana_service_account_token" {
  count = var.enable_grafana_dashboards && var.create_grafana_service_account ? 1 : 0

  name         = "grafana-service-account-token"
  value        = grafana_service_account_token.terraform[0].key
  key_vault_id = azurerm_key_vault.this.id

  content_type = "text/plain"
  tags         = local.tags

  depends_on = [
    azurerm_role_assignment.terraform_keyvault_secrets_officer
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}
