#------------------------------------------------------------------------------
# Grafana Provider Configuration
# Uses the Azure Managed Grafana endpoint with service account token authentication
#
# IMPORTANT: Dashboard provisioning requires a two-phase deployment:
# 1. First deploy with enable_grafana_dashboards = false (or no token)
# 2. Create a service account token in Grafana UI
# 3. Re-deploy with enable_grafana_dashboards = true and the token
#------------------------------------------------------------------------------

# Local to determine if we can actually provision dashboards
# Requires both the flag to be true AND a valid token to be provided
locals {
  can_provision_dashboards = var.enable_grafana_dashboards && var.grafana_service_account_token != ""
}

provider "grafana" {
  # Only configure if we have a token - otherwise provider will fail
  url  = local.can_provision_dashboards ? azurerm_dashboard_grafana.this.endpoint : "https://placeholder.grafana.azure.com"
  auth = local.can_provision_dashboards ? var.grafana_service_account_token : "placeholder"
}

#------------------------------------------------------------------------------
# Grafana Folder for MCCS Dashboards
#------------------------------------------------------------------------------

resource "grafana_folder" "mccs" {
  count = local.can_provision_dashboards ? 1 : 0

  title = "MCCS Observability"
  uid   = "mccs-observability"

  depends_on = [azurerm_dashboard_grafana.this]
}

#------------------------------------------------------------------------------
# Dashboard: MCCS Overview
# Consolidated view of all ExpressRoute and Direct Connect circuits
#------------------------------------------------------------------------------

resource "grafana_dashboard" "mccs_overview" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  # Use templatefile() to inject known circuit configuration
  # Grafana template variables are escaped with $${...}
  config_json = templatefile("${path.module}/dashboards/mccs_overview.json.tftpl", {
    subscription_id        = local.subscription_id_connectivity
    default_resource_group = local.default_expressroute_resource_group
    circuit_names          = local.expressroute_circuit_names
    circuits               = var.expressroute_circuits
  })

  depends_on = [grafana_folder.mccs]
}

#------------------------------------------------------------------------------
# Dashboard: ExpressRoute Health
# Detailed health metrics for Azure ExpressRoute circuits
#------------------------------------------------------------------------------

resource "grafana_dashboard" "expressroute_health" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/expressroute_health.json.tftpl", {
    subscription_id        = local.subscription_id_connectivity
    default_resource_group = local.default_expressroute_resource_group
    circuit_names          = local.expressroute_circuit_names
    circuits               = var.expressroute_circuits
  })

  depends_on = [grafana_folder.mccs]
}

#------------------------------------------------------------------------------
# Dashboard: Circuit Inventory
# Network documentation from Netbox
#------------------------------------------------------------------------------

resource "grafana_dashboard" "circuit_inventory" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/circuit_inventory.json.tftpl", {
    subscription_id        = local.subscription_id_connectivity
    default_resource_group = local.default_expressroute_resource_group
    circuits               = var.expressroute_circuits
    netbox_url             = "http://${azurerm_container_group.netbox.ip_address}:8080"
  })

  depends_on = [grafana_folder.mccs]
}

#------------------------------------------------------------------------------
# Grafana Data Source: Azure Monitor
# Automatically configured with the Grafana managed identity
#------------------------------------------------------------------------------

# Note: Azure Managed Grafana comes with a pre-configured "Azure Monitor" data source.
# We create an additional one with MCCS-specific configuration if needed.
# The built-in data source is typically sufficient for most use cases.

resource "grafana_data_source" "azure_monitor" {
  count = local.can_provision_dashboards ? 1 : 0

  name = "Azure Monitor - MCCS"
  type = "grafana-azure-monitor-datasource"

  json_data_encoded = jsonencode({
    cloudName               = "azuremonitor"
    subscriptionId          = local.subscription_id_connectivity
    azureAuthType           = "msi"
    tenantId                = data.azurerm_client_config.current.tenant_id
    azureLogAnalyticsSameAs = true
    # Note: When using MSI auth, no clientId is needed - Azure Managed Grafana
    # automatically uses its system-assigned managed identity
  })

  # Don't set as default - the built-in Azure Monitor data source is the default
  is_default = false

  depends_on = [azurerm_dashboard_grafana.this]
}

#------------------------------------------------------------------------------
# Grafana Data Source: Log Analytics
# For querying diagnostic logs via KQL
#------------------------------------------------------------------------------

resource "grafana_data_source" "log_analytics" {
  count = local.can_provision_dashboards ? 1 : 0

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

  depends_on = [azurerm_dashboard_grafana.this]
}

#------------------------------------------------------------------------------
# Grafana Data Source: Prometheus
# For custom metrics from Netbox exporter and future AWS integration
#------------------------------------------------------------------------------

resource "grafana_data_source" "prometheus" {
  count = local.can_provision_dashboards ? 1 : 0

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

  depends_on = [azurerm_dashboard_grafana.this]
}

#------------------------------------------------------------------------------
# Grafana Service Account for Terraform Management
# Note: This is created once and the token should be stored securely
#------------------------------------------------------------------------------

resource "grafana_service_account" "terraform" {
  count = local.can_provision_dashboards && var.create_grafana_service_account ? 1 : 0

  name        = "terraform-automation"
  role        = "Admin"
  is_disabled = false

  depends_on = [azurerm_dashboard_grafana.this]
}

resource "grafana_service_account_token" "terraform" {
  count = local.can_provision_dashboards && var.create_grafana_service_account ? 1 : 0

  name               = "terraform-token"
  service_account_id = grafana_service_account.terraform[0].id

  # Token expires in 1 year - should be rotated
  seconds_to_live = 31536000
}

# Store the service account token in Key Vault for future use
resource "azurerm_key_vault_secret" "grafana_service_account_token" {
  count = local.can_provision_dashboards && var.create_grafana_service_account ? 1 : 0

  name         = "grafana-service-account-token"
  value        = grafana_service_account_token.terraform[0].key
  key_vault_id = azurerm_key_vault.this.id

  content_type = "text/plain"
  tags         = local.tags

  # Depends on Key Vault being fully provisioned with RBAC
  depends_on = [
    azurerm_key_vault.this
  ]
}
