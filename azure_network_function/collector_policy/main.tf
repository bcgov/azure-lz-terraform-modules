resource "azurerm_network_function_collector_policy" "this" {
  name                 = var.collector_policy_name
  traffic_collector_id = var.traffic_collector_id
  location             = var.location

  ipfx_emission {
    destination_types = var.ipfx_emission_destination_types
  }

  ipfx_ingestion {
    source_resource_ids = var.ipfx_ingestion_source_resource_ids
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = "${var.collector_policy_name}-diag"
  target_resource_id             = var.traffic_collector_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated" # 'Dedicated' = resource specific tables

  enabled_log {
    category = "ExpressRouteCircuitIpfix"
  }
}
