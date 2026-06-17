module "network_flow_logs" {
  source  = "Azure/avm-res-network-networkwatcher/azurerm"
  version = "0.3.0"

  location             = var.primary_location
  network_watcher_id   = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkWatchers/NetworkWatcher_%s", var.subscription_id_connectivity, local.NetworkWatcherRGName, lower(var.primary_location))
  network_watcher_name = "NetworkWatcher_${lower(var.primary_location)}"
  resource_group_name  = local.NetworkWatcherRGName
  enable_telemetry     = false
  flow_logs = {
    (var.virtual_network_name) = {
      enabled              = true
      name                 = "${var.virtual_network_name}-vwan-spoke-networking-flowlog"
      target_resource_id   = azurerm_virtual_network.ghrunners_vnet.id
      network_watcher_name = format("NetworkWatcher_%s", lower(var.primary_location))
      storage_account_id   = var.vnet_flow_logs_storage_account_id
      version              = 2

      retention_policy = {
        days    = 90
        enabled = true
      }

      traffic_analytics = {
        enabled               = true
        interval_in_minutes   = 60
        workspace_id          = var.workspace_id
        workspace_region      = var.primary_location
        workspace_resource_id = var.workspace_resource_id
      }
    }
  }
}
