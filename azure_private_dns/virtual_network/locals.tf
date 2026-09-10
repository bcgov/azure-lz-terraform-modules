locals {
  environment_suffix                  = lower(var.environment)
  network_watcher_location            = var.primary_location
  network_watcher_resource_group_name = "NetworkWatcherRG"
}
