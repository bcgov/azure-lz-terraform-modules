module "network_flow_logs" {
  source   = "Azure/avm-res-network-networkwatcher/azurerm"
  version  = "0.3.0"
  for_each = { for sub in var.subscriptions : sub.name => sub if try(sub.network.enabled, false) }

  location             = var.primary_location
  network_watcher_id   = format("%s/resourceGroups/%s/providers/Microsoft.Network/networkWatchers/NetworkWatcher_%s", module.lz_vending[each.key].subscription_resource_id, local.NetworkWatcherRGName, lower(var.primary_location))
  network_watcher_name = "NetworkWatcher_${lower(var.primary_location)}"
  resource_group_name  = local.NetworkWatcherRGName
  enable_telemetry     = false
  flow_logs = {
    (each.value.name) = {
      enabled              = true
      name                 = "${var.license_plate}-${each.value.name}-vwan-spoke-${var.license_plate}-${each.value.name}-networking-flowlog"
      target_resource_id   = module.lz_vending[each.value.name].virtual_network_resource_ids["vwan_spoke"]
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
