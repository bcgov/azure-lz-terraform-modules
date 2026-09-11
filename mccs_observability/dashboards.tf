#------------------------------------------------------------------------------
# Grafana Provider Configuration
# Uses the Azure Managed Grafana endpoint with service account token authentication
#
# The token comes from (in order of precedence):
# 1. var.grafana_service_account_token (e.g. TF_VAR or CI secret)
# 2. the grafana-service-account-token secret in the module's Key Vault
#
# Bootstrap for a brand new environment: the Grafana API itself needs an
# existing token, so the first token must be created manually in the Grafana UI
# (Administration > Users and access > Service accounts) and stored as the
# grafana-service-account-token secret in the Key Vault - or passed via var.
# Until a token is available, deploy with enable_grafana_dashboards = false:
# all other infrastructure deploys and Grafana resources are skipped.
#------------------------------------------------------------------------------

locals {
  grafana_token_from_var = var.grafana_service_account_token != ""
  # Only attempt the Key Vault lookup when dashboards are wanted and no token
  # was passed. In a brand-new environment the secret does not exist yet, so
  # keep enable_grafana_dashboards = false for the first apply.
  grafana_token_from_keyvault = !local.grafana_token_from_var && var.enable_grafana_dashboards

  can_provision_dashboards = var.enable_grafana_dashboards && (local.grafana_token_from_var || local.grafana_token_from_keyvault)

  grafana_auth = local.grafana_token_from_var ? var.grafana_service_account_token : (
    local.grafana_token_from_keyvault ? data.azurerm_key_vault_secret.grafana_token[0].value : "placeholder"
  )

  # Azure Managed Grafana's built-in Azure Monitor source (MSI). Custom
  # grafana_data_source copies use a Grafana 12-incompatible credential
  # shape and break Log Analytics unless they also set azureCredentials.
  azure_monitor_uid          = "azure-monitor-oob"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
}

# Read the stored service account token when none was passed in
# (requires the identity running terraform to have Key Vault Secrets User)
data "azurerm_key_vault_secret" "grafana_token" {
  count = local.grafana_token_from_keyvault ? 1 : 0

  name         = "grafana-service-account-token"
  key_vault_id = azurerm_key_vault.this.id
}

provider "grafana" {
  # Static placeholder URL/auth keeps the provider happy when there is nothing
  # to manage; no Grafana resources are created in that case.
  url  = local.can_provision_dashboards ? azurerm_dashboard_grafana.this.endpoint : "https://placeholder.grafana.azure.com"
  auth = local.can_provision_dashboards ? local.grafana_auth : "placeholder"
}

#------------------------------------------------------------------------------
# Grafana Folder for MCCS Dashboards
#------------------------------------------------------------------------------

resource "grafana_folder" "home" {
  count = local.can_provision_dashboards ? 1 : 0

  title = "Landing Zone Home"
  uid   = "lz-home"

  depends_on = [azurerm_dashboard_grafana.this]
}

resource "grafana_folder" "mccs" {
  count = local.can_provision_dashboards ? 1 : 0

  title = "Connectivity"
  uid   = "mccs-observability"

  depends_on = [azurerm_dashboard_grafana.this]
}

resource "grafana_folder" "lz_operations" {
  count = local.can_provision_dashboards ? 1 : 0

  title = "Platform"
  uid   = "lz-operations"

  depends_on = [azurerm_dashboard_grafana.this]
}

resource "grafana_folder" "security" {
  count = local.can_provision_dashboards ? 1 : 0

  title = "Security"
  uid   = "lz-security"

  depends_on = [azurerm_dashboard_grafana.this]
}

#------------------------------------------------------------------------------
# Dashboard: Landing Zone Home
#------------------------------------------------------------------------------

resource "grafana_dashboard" "landing_zone_home" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.home[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/landing_zone_home.json.tftpl", {
    subscription_id           = local.subscription_id_connectivity
    azure_monitor_uid         = local.azure_monitor_uid
    arg_subscriptions         = jsonencode(local.grafana_arg_subscription_ids)
    activity_log_workspace_id = local.activity_log_workspace_id
    er_resource_group         = local.default_expressroute_resource_group
    er_circuit_name           = length(local.expressroute_circuit_names) > 0 ? local.expressroute_circuit_names[0] : ""
    hub_resource_group        = local.virtual_hub_resource_group
    hub_name                  = local.virtual_hub_name
    vpn_resource_group        = local.default_vpn_gateway_resource_group
    vpn_gateway_name          = length(local.vpn_gateway_names) > 0 ? local.vpn_gateway_names[0] : ""
    fw_resource_group         = local.default_firewall_resource_group
    fw_name                   = length(local.azure_firewall_names) > 0 ? local.azure_firewall_names[0] : ""
  })

  depends_on = [grafana_folder.home]
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
    subscription_id            = local.subscription_id_connectivity
    default_resource_group     = local.default_expressroute_resource_group
    circuit_names              = local.expressroute_circuit_names
    circuits                   = var.expressroute_circuits
    azure_monitor_uid          = local.azure_monitor_uid
    log_analytics_workspace_id = local.log_analytics_workspace_id
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
    subscription_id                = local.subscription_id_connectivity
    default_resource_group         = local.default_expressroute_resource_group
    default_gateway_resource_group = local.default_virtual_hub_express_route_gateway_resource_group
    gateway_metric_namespace       = local.express_route_gateway_metric_namespace
    default_gateway_name           = length(local.virtual_hub_express_route_gateway_names) > 0 ? local.virtual_hub_express_route_gateway_names[0] : ""
    circuit_names                  = local.expressroute_circuit_names
    circuits                       = var.expressroute_circuits
    azure_monitor_uid              = local.azure_monitor_uid
    log_analytics_uid              = local.azure_monitor_uid
    log_analytics_workspace_id     = local.log_analytics_workspace_id
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
    azureCredentials = {
      authType = "msi"
    }
    cloudName               = "azuremonitor"
    subscriptionId          = local.subscription_id_connectivity
    tenantId                = data.azurerm_client_config.current.tenant_id
    azureLogAnalyticsSameAs = true
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
    azureCredentials = {
      authType = "msi"
    }
    cloudName                    = "azuremonitor"
    subscriptionId               = local.subscription_id_connectivity
    tenantId                     = data.azurerm_client_config.current.tenant_id
    logAnalyticsDefaultWorkspace = azurerm_log_analytics_workspace.this.id
    azureLogAnalyticsSameAs      = true
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
    azurerm_role_assignment.terraform_spn_secrets_officer,
    azurerm_role_assignment.cloud_team_secrets_officer,
    azurerm_private_endpoint.keyvault
  ]
}

#------------------------------------------------------------------------------
# Landing Zone Operations: Dashboard - Virtual WAN Hub Health
#
# Hub router capacity (Routing Infrastructure Units), spoke VM utilization,
# data processed, and hub BGP/route health. Targets the vWAN hub the
# observability VNet connects to (var.virtual_hub_id).
#------------------------------------------------------------------------------

resource "grafana_dashboard" "vwan_hub_health" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/vwan_hub_health.json.tftpl", {
    subscription_id            = local.subscription_id_connectivity
    default_resource_group     = local.virtual_hub_resource_group
    hub_name                   = local.virtual_hub_name
    azure_monitor_uid          = local.azure_monitor_uid
    log_analytics_workspace_id = local.log_analytics_workspace_id
  })

  depends_on = [grafana_folder.mccs]
}

#------------------------------------------------------------------------------
# Landing Zone Operations: Dashboard - VPN Gateway Health
#
# S2S VPN tunnel bandwidth, packet drops, BGP routes, and diagnostic logs.
# Only provisioned when vpn_gateways is provided.
#------------------------------------------------------------------------------

resource "grafana_dashboard" "vpn_gateway_health" {
  count = local.can_provision_dashboards && length(var.vpn_gateways) > 0 ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/vpn_gateway_health.json.tftpl", {
    subscription_id            = local.subscription_id_connectivity
    default_resource_group     = local.default_vpn_gateway_resource_group
    default_gateway_name       = local.vpn_gateway_names[0]
    azure_monitor_uid          = local.azure_monitor_uid
    log_analytics_uid          = local.azure_monitor_uid
    log_analytics_workspace_id = local.log_analytics_workspace_id
  })

  depends_on = [grafana_folder.mccs]
}

#------------------------------------------------------------------------------
# Connectivity: Dashboard - Azure Firewall
#------------------------------------------------------------------------------

resource "grafana_dashboard" "azure_firewall_health" {
  count = local.can_provision_dashboards && length(var.azure_firewalls) > 0 ? 1 : 0

  folder    = grafana_folder.mccs[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/azure_firewall_health.json.tftpl", {
    subscription_id            = local.subscription_id_connectivity
    default_resource_group     = local.default_firewall_resource_group
    default_firewall_name      = local.azure_firewall_names[0]
    azure_monitor_uid          = local.azure_monitor_uid
    log_analytics_uid          = local.azure_monitor_uid
    log_analytics_workspace_id = local.activity_log_workspace_id
  })

  depends_on = [grafana_folder.mccs]
}

#------------------------------------------------------------------------------
# Landing Zone Operations: Dashboard - Platform Changes (Activity Log)
#
# Subscription control-plane change feed from activity logs routed to
# the workspace by the activity log diagnostic setting.
#------------------------------------------------------------------------------

resource "grafana_dashboard" "platform_changes" {
  count = local.can_provision_dashboards && var.enable_activity_log_diagnostics ? 1 : 0

  folder    = grafana_folder.lz_operations[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/platform_changes.json.tftpl", {
    subscription_id            = local.subscription_id_connectivity
    azure_monitor_uid          = local.azure_monitor_uid
    log_analytics_uid          = local.azure_monitor_uid
    log_analytics_workspace_id = local.activity_log_workspace_id
  })

  depends_on = [grafana_folder.lz_operations]
}

#------------------------------------------------------------------------------
# Landing Zone Operations: Dashboard - Resource Inventory & Policy
#
# Resource counts, recently created resources, and policy compliance via
# Azure Resource Graph through the Azure Monitor data source.
#------------------------------------------------------------------------------

resource "grafana_dashboard" "resource_inventory_policy" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.lz_operations[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/resource_inventory_policy.json.tftpl", {
    subscription_id   = local.subscription_id_connectivity
    azure_monitor_uid = local.azure_monitor_uid
    arg_subscriptions = jsonencode(local.grafana_arg_subscription_ids)
  })

  depends_on = [grafana_folder.lz_operations]
}

#------------------------------------------------------------------------------
# Landing Zone Operations: Dashboard - Security Posture (Defender)
#
# Defender for Cloud secure score and unhealthy security assessments
# via Azure Resource Graph. Requires Defender for Cloud (free
# foundational CSPM tier) to be enabled on the subscription.
#------------------------------------------------------------------------------

resource "grafana_dashboard" "security_posture" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.security[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/security_posture.json.tftpl", {
    subscription_id   = local.subscription_id_connectivity
    azure_monitor_uid = local.azure_monitor_uid
    arg_subscriptions = jsonencode(local.grafana_arg_subscription_ids)
  })

  depends_on = [grafana_folder.security]
}

#------------------------------------------------------------------------------
# Landing Zone Operations: Dashboard - Key Vault Access
#
# Key Vault audit events (secret access, denied attempts, callers) from
# the AuditEvent diagnostic data already routed to the workspace.
#------------------------------------------------------------------------------

resource "grafana_dashboard" "key_vault_access" {
  count = local.can_provision_dashboards ? 1 : 0

  folder    = grafana_folder.security[0].id
  overwrite = true

  config_json = templatefile("${path.module}/dashboards/key_vault_access.json.tftpl", {
    subscription_id            = local.subscription_id_connectivity
    azure_monitor_uid          = local.azure_monitor_uid
    log_analytics_uid          = local.azure_monitor_uid
    log_analytics_workspace_id = local.log_analytics_workspace_id
  })

  depends_on = [grafana_folder.security]
}
