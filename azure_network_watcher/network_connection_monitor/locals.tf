locals {
  # subscription_id_connectivity = coalesce(var.subscription_id_connectivity, local.subscription_id_management)
  # subscription_id_management   = coalesce(var.subscription_id_management, data.azurerm_client_config.current.subscription_id)

  subscription_id_connectivity = coalesce(var.subscription_id_connectivity, data.azurerm_client_config.current.subscription_id)

  network_watcher_id = format("/subscriptions/%s/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/NetworkWatcher_${lower(var.location)}",
    local.subscription_id_connectivity
  )
}
