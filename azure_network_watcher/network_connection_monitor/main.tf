module "network_connection_monitor" {
  source  = "Azure/avm-res-network-networkwatcher/azurerm"
  version = ">= 0.3.0"

  location             = var.location
  network_watcher_id   = local.network_watcher_id
  network_watcher_name = "NetworkWatcher_${lower(var.location)}"
  resource_group_name  = "NetworkWatcherRG" # Universal?

  condition_monitor = var.condition_monitor
}
