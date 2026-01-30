#------------------------------------------------------------------------------
# Logic App Workflow (Alert Router)
#------------------------------------------------------------------------------

resource "azurerm_logic_app_workflow" "alert_router" {
  count = var.enable_alerting ? 1 : 0

  name                = local.logic_app_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags,
      # Ignore definition changes as they may be managed via Azure Portal
      # or separate Logic App action resources
      parameters
    ]
  }
}

#------------------------------------------------------------------------------
# Logic App HTTP Trigger
#------------------------------------------------------------------------------

resource "azurerm_logic_app_trigger_http_request" "alert_trigger" {
  count = var.enable_alerting ? 1 : 0

  name         = "When_an_Azure_Monitor_alert_is_triggered"
  logic_app_id = azurerm_logic_app_workflow.alert_router[0].id

  schema = jsonencode({
    type = "object"
    properties = {
      schemaId = {
        type = "string"
      }
      data = {
        type = "object"
        properties = {
          essentials = {
            type = "object"
            properties = {
              alertId = {
                type = "string"
              }
              alertRule = {
                type = "string"
              }
              severity = {
                type = "string"
              }
              signalType = {
                type = "string"
              }
              monitorCondition = {
                type = "string"
              }
              monitoringService = {
                type = "string"
              }
              alertTargetIDs = {
                type  = "array"
                items = { type = "string" }
              }
              configurationItems = {
                type  = "array"
                items = { type = "string" }
              }
              originAlertId = {
                type = "string"
              }
              firedDateTime = {
                type = "string"
              }
              description = {
                type = "string"
              }
              essentialsVersion = {
                type = "string"
              }
              alertContextVersion = {
                type = "string"
              }
            }
          }
        }
      }
    }
  })
}

#------------------------------------------------------------------------------
# Logic App Actions (Post to Teams)
# Note: Full workflow definition should be managed via azapi or imported
# This provides the basic structure
#------------------------------------------------------------------------------

resource "azurerm_logic_app_action_custom" "parse_alert" {
  count = var.enable_alerting ? 1 : 0

  name         = "Parse_Alert_JSON"
  logic_app_id = azurerm_logic_app_workflow.alert_router[0].id

  body = jsonencode({
    type = "ParseJson"
    inputs = {
      content = "@triggerBody()"
      schema = {
        type = "object"
        properties = {
          schemaId = { type = "string" }
          data = {
            type       = "object"
            properties = {}
          }
        }
      }
    }
    runAfter = {}
  })
}

#------------------------------------------------------------------------------
# Action Group
#------------------------------------------------------------------------------

resource "azurerm_monitor_action_group" "this" {
  count = var.enable_alerting ? 1 : 0

  name                = local.action_group_name
  resource_group_name = azurerm_resource_group.this.name
  short_name          = "mccs-alerts"

  # Email notification (fallback)
  email_receiver {
    name                    = "cloud-team-email"
    email_address           = var.cloud_team_email
    use_common_alert_schema = true
  }

  # Logic App receiver
  logic_app_receiver {
    name                    = "logic-app-alert-router"
    resource_id             = azurerm_logic_app_workflow.alert_router[0].id
    callback_url            = azurerm_logic_app_trigger_http_request.alert_trigger[0].callback_url
    use_common_alert_schema = true
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Alert Rules for ExpressRoute Circuits
#------------------------------------------------------------------------------

# BGP Availability Alert (Critical - Sev0)
resource "azurerm_monitor_metric_alert" "bgp_availability" {
  for_each = var.enable_alerting ? var.expressroute_circuits : {}

  name                = "MCCS BGP Down - ${each.key}"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [data.azurerm_express_route_circuit.circuits[each.key].id]
  description         = "BGP availability dropped below ${var.bgp_availability_threshold}% on ${each.key} ExpressRoute circuit."
  severity            = 0 # Sev0 - Critical
  frequency           = var.alert_evaluation_frequency
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.Network/expressRouteCircuits"
    metric_name      = "BgpAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.bgp_availability_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# ARP Availability Alert (Critical - Sev0)
resource "azurerm_monitor_metric_alert" "arp_availability" {
  for_each = var.enable_alerting ? var.expressroute_circuits : {}

  name                = "MCCS ARP Down - ${each.key}"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [data.azurerm_express_route_circuit.circuits[each.key].id]
  description         = "ARP availability dropped below ${var.arp_availability_threshold}% on ${each.key} ExpressRoute circuit."
  severity            = 0 # Sev0 - Critical
  frequency           = var.alert_evaluation_frequency
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.Network/expressRouteCircuits"
    metric_name      = "ArpAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.arp_availability_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Bandwidth High Utilization (Warning - Sev2)
resource "azurerm_monitor_metric_alert" "bandwidth_warning" {
  for_each = var.enable_alerting ? var.expressroute_circuits : {}

  name                = "MCCS Bandwidth High - ${each.key}"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [data.azurerm_express_route_circuit.circuits[each.key].id]
  description         = "Bandwidth utilization exceeded ${var.bandwidth_warning_threshold}% on ${each.key} ExpressRoute circuit."
  severity            = 2 # Sev2 - Warning
  frequency           = "PT15M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Network/expressRouteCircuits"
    metric_name      = "BitsInPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    # Calculate threshold based on circuit bandwidth (80% of capacity)
    threshold = each.value.bandwidth_mbps * 1000000 * (var.bandwidth_warning_threshold / 100)
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Bandwidth Critical Utilization (Error - Sev1)
resource "azurerm_monitor_metric_alert" "bandwidth_critical" {
  for_each = var.enable_alerting ? var.expressroute_circuits : {}

  name                = "MCCS Bandwidth Critical - ${each.key}"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [data.azurerm_express_route_circuit.circuits[each.key].id]
  description         = "Bandwidth utilization exceeded ${var.bandwidth_critical_threshold}% on ${each.key} ExpressRoute circuit."
  severity            = 1 # Sev1 - Error
  frequency           = var.alert_evaluation_frequency
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.Network/expressRouteCircuits"
    metric_name      = "BitsInPerSecond"
    aggregation      = "Average"
    operator         = "GreaterThan"
    # Calculate threshold based on circuit bandwidth (95% of capacity)
    threshold = each.value.bandwidth_mbps * 1000000 * (var.bandwidth_critical_threshold / 100)
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Alert Rules for ExpressRoute Gateways
#------------------------------------------------------------------------------

# Gateway Health Alert (Critical - Sev0)
resource "azurerm_monitor_metric_alert" "gateway_health" {
  for_each = var.enable_alerting ? var.expressroute_gateways : {}

  name                = "MCCS Gateway Unhealthy - ${each.key}"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [data.azurerm_virtual_network_gateway.gateways[each.key].id]
  description         = "ExpressRoute gateway ${each.key} is unhealthy."
  severity            = 0 # Sev0 - Critical
  frequency           = var.alert_evaluation_frequency
  window_size         = var.alert_window_size

  criteria {
    metric_namespace = "Microsoft.Network/virtualNetworkGateways"
    metric_name      = "ExpressRouteGatewayHealthState"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Logic App Diagnostic Settings
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "logic_app" {
  count = var.enable_alerting ? 1 : 0

  name                       = "diag-${azurerm_logic_app_workflow.alert_router[0].name}"
  target_resource_id         = azurerm_logic_app_workflow.alert_router[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "WorkflowRuntime"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
