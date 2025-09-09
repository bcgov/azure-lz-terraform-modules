locals {
  subscription_id_connectivity = coalesce(var.subscription_id_connectivity, data.azurerm_client_config.current.subscription_id)

  # IP range validation regex pattern (extracted for readability)
  ip_range_regex = "^((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\-((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)$"
}
