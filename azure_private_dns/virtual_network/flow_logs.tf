module "network_flow_logs" {
  # IMPORTANT: Traffic Analytics does not support Management Group permissions inheritance! Therefore, direct assignment on the target Subscription is required.
  # See: https://learn.microsoft.com/en-us/azure/network-watcher/secure-network-watcher#identity-and-access-management and https://learn.microsoft.com/en-us/azure/network-watcher/required-rbac-permissions#traffic-analytics
  source  = "Azure/avm-res-network-networkwatcher/azurerm"
  version = "0.3.2"

  location             = local.network_watcher_location
  network_watcher_id   = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkWatchers/NetworkWatcher_%s", var.subscription_id_connectivity, local.network_watcher_resource_group_name, local.network_watcher_location)
  network_watcher_name = "NetworkWatcher_${local.network_watcher_location}"
  resource_group_name  = local.network_watcher_resource_group_name
  enable_telemetry     = false
  flow_logs = {
    (azurerm_virtual_network.this.name) = {
      enabled              = true
      name                 = "${azurerm_virtual_network.this.name}-network-flowlog" # The name can be up to 80 characters long
      target_resource_id   = azurerm_virtual_network.this.id
      network_watcher_name = format("NetworkWatcher_%s", local.network_watcher_location)
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
        workspace_region      = local.network_watcher_location
        workspace_resource_id = var.workspace_resource_id
      }
    }
  }
}
