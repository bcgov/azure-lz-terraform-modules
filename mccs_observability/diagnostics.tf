#------------------------------------------------------------------------------
# Diagnostic Settings for ExpressRoute Circuits
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "expressroute_circuits" {
  for_each = var.enable_expressroute_diagnostics ? var.expressroute_circuits : {}

  name                       = "diag-mccs-${each.key}"
  target_resource_id         = data.azurerm_express_route_circuit.circuits[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  # ExpressRoute Circuit Logs
  enabled_log {
    category = "PeeringRouteLog"
  }

  # ExpressRoute Circuit Metrics
  enabled_metric {
    category = "AllMetrics"
  }
}

#------------------------------------------------------------------------------
# Diagnostic Settings for ExpressRoute Gateways
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "expressroute_gateways" {
  for_each = var.enable_expressroute_diagnostics ? var.expressroute_gateways : {}

  name                       = "diag-mccs-${each.key}"
  target_resource_id         = data.azurerm_virtual_network_gateway.gateways[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  # Gateway Diagnostic Logs
  enabled_log {
    category = "GatewayDiagnosticLog"
  }

  enabled_log {
    category = "TunnelDiagnosticLog"
  }

  enabled_log {
    category = "RouteDiagnosticLog"
  }

  enabled_log {
    category = "IKEDiagnosticLog"
  }

  # Gateway Metrics
  enabled_metric {
    category = "AllMetrics"
  }
}

#------------------------------------------------------------------------------
# Diagnostic Settings for Key Vault
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-${azurerm_key_vault.this.name}"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

#------------------------------------------------------------------------------
# Diagnostic Settings for Storage Accounts
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "storage_netbox" {
  name                       = "diag-${azurerm_storage_account.netbox.name}"
  target_resource_id         = azurerm_storage_account.netbox.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_metric {
    category = "Transaction"
  }

  enabled_metric {
    category = "Capacity"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_prometheus" {
  name                       = "diag-${azurerm_storage_account.prometheus.name}"
  target_resource_id         = azurerm_storage_account.prometheus.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_metric {
    category = "Transaction"
  }

  enabled_metric {
    category = "Capacity"
  }
}

#------------------------------------------------------------------------------
# Resource Health Alerts (Optional)
# These provide notifications when Azure itself has issues affecting resources
#------------------------------------------------------------------------------

resource "azurerm_monitor_activity_log_alert" "resource_health" {
  count = var.enable_alerting ? 1 : 0

  name                = "alert-mccs-resource-health"
  resource_group_name = azurerm_resource_group.this.name
  location            = "global"
  scopes              = [azurerm_resource_group.this.id]
  description         = "Alert when any MCCS resource has a health event"

  criteria {
    category = "ResourceHealth"

    resource_health {
      current  = ["Degraded", "Unavailable"]
      previous = ["Available"]
      reason   = ["PlatformInitiated", "UserInitiated", "Unknown"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = local.tags
}
