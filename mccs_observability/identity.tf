#------------------------------------------------------------------------------
# User Assigned Managed Identity for Container Instances
#------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "aci" {
  name                = "id-${local.resource_prefix}-aci"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  tags                = local.tags
}

#------------------------------------------------------------------------------
# RBAC Assignments for Grafana Managed Identity
#------------------------------------------------------------------------------

# Grafana needs Monitoring Reader on the connectivity subscription
resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  scope                = "/subscriptions/${local.subscription_id_connectivity}"
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

# Grafana needs Reader on ExpressRoute circuits for metrics
resource "azurerm_role_assignment" "grafana_expressroute_reader" {
  for_each = local.expressroute_circuit_ids

  scope                = each.value
  role_definition_name = "Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

# Grafana needs Reader on ExpressRoute gateways for metrics
resource "azurerm_role_assignment" "grafana_gateway_reader" {
  for_each = local.expressroute_gateway_ids

  scope                = each.value
  role_definition_name = "Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

# Grafana needs access to Log Analytics
resource "azurerm_role_assignment" "grafana_log_analytics_reader" {
  scope                = azurerm_log_analytics_workspace.this.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

#------------------------------------------------------------------------------
# RBAC Assignments for Cloud Team
#------------------------------------------------------------------------------

# Cloud Team - Contributor on Resource Group
resource "azurerm_role_assignment" "cloud_team_contributor" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = var.cloud_team_group_id
}

# Cloud Team - Grafana Admin
resource "azurerm_role_assignment" "cloud_team_grafana_admin" {
  scope                = azurerm_dashboard_grafana.this.id
  role_definition_name = "Grafana Admin"
  principal_id         = var.cloud_team_group_id
}

#------------------------------------------------------------------------------
# RBAC Assignments for NOC Team (Optional)
#------------------------------------------------------------------------------

# NOC Team - Grafana Editor
resource "azurerm_role_assignment" "noc_team_grafana_editor" {
  count = var.noc_team_group_id != null ? 1 : 0

  scope                = azurerm_dashboard_grafana.this.id
  role_definition_name = "Grafana Editor"
  principal_id         = var.noc_team_group_id
}

#------------------------------------------------------------------------------
# RBAC Assignments for Service Desk (Optional)
#------------------------------------------------------------------------------

# Service Desk - Grafana Viewer
resource "azurerm_role_assignment" "service_desk_grafana_viewer" {
  count = var.service_desk_group_id != null ? 1 : 0

  scope                = azurerm_dashboard_grafana.this.id
  role_definition_name = "Grafana Viewer"
  principal_id         = var.service_desk_group_id
}

#------------------------------------------------------------------------------
# RBAC for Container Instance Managed Identity
#------------------------------------------------------------------------------

# ACI identity needs access to Key Vault secrets
resource "azurerm_role_assignment" "aci_keyvault_secrets_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aci.principal_id
}

# ACI identity needs access to storage for Prometheus data
resource "azurerm_role_assignment" "aci_storage_contributor" {
  scope                = azurerm_storage_account.prometheus.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aci.principal_id
}
