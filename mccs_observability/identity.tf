#------------------------------------------------------------------------------
# RBAC Assignments for Grafana Managed Identity
#------------------------------------------------------------------------------

# Grafana needs Monitoring Reader for Azure Monitor metrics/logs, and Reader
# for Azure Resource Graph. Both are assigned at the landing zone management
# group when grafana_monitoring_management_group_id is set; otherwise they
# stay on the connectivity subscription.
resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  scope                = local.grafana_monitoring_scope
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "grafana_reader" {
  scope                = local.grafana_monitoring_scope
  role_definition_name = "Reader"
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

# Grafana needs Reader on the Virtual WAN hub for hub metrics
resource "azurerm_role_assignment" "grafana_virtual_hub_reader" {
  scope                = var.virtual_hub_id
  role_definition_name = "Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

# Grafana needs Reader on VPN gateways for metrics
resource "azurerm_role_assignment" "grafana_vpn_gateway_reader" {
  for_each = local.vpn_gateway_ids

  scope                = each.value
  role_definition_name = "Reader"
  principal_id         = azurerm_dashboard_grafana.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "grafana_firewall_reader" {
  for_each = local.azure_firewall_ids

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

# When Platform Changes reads the CAF/platform workspace instead of this
# module's workspace, grant the same reader there.
resource "azurerm_role_assignment" "grafana_activity_log_workspace_reader" {
  count = var.activity_log_workspace_id != null && var.activity_log_workspace_id != azurerm_log_analytics_workspace.this.id ? 1 : 0

  scope                = var.activity_log_workspace_id
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
  principal_id         = local.cloud_team_group_id
}

# Cloud Team - Grafana Admin
resource "azurerm_role_assignment" "cloud_team_grafana_admin" {
  scope                = azurerm_dashboard_grafana.this.id
  role_definition_name = "Grafana Admin"
  principal_id         = local.cloud_team_group_id
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
