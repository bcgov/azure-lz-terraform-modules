locals {
  subscription_id_connectivity = coalesce(var.subscription_id_connectivity, data.azurerm_client_config.current.subscription_id)
}
