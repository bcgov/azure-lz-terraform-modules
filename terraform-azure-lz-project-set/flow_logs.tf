resource "azurerm_network_watcher_flow_log" "flowlogs" {
  for_each             = { for sub in var.subscriptions : sub.name => sub if try(sub.network.enabled, false) }
  network_watcher_name = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkWatchers/NetworkWatcher_%s", module.lz_vending[each.key].subscription_resource_id, local.NetworkWatcherRGName, lower(var.primary_location))
  resource_group_name  = local.NetworkWatcherRGName
  name                 = "${var.license_plate}-${each.value.name}-vwan-spoke-${var.license_plate}-${each.value.name}-networking-flowlog"

  target_resource_id = module.lz_vending[each.value.name].virtual_network_resource_ids["vwan_spoke"]
  storage_account_id = var.vnet_flow_logs_storage_account_id
  enabled            = true

  retention_policy {
    enabled = true
    days    = 3
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.workspace_id
    workspace_region      = var.primary_location
    workspace_resource_id = var.workspace_resource_id
    interval_in_minutes   = 60
  }
}
