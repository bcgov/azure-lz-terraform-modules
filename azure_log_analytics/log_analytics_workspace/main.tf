resource "azurerm_resource_group" "law" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_workspace_name
  resource_group_name = azurerm_resource_group.law.name
  location            = azurerm_resource_group.law.location

  allow_resource_only_permissions = var.allow_resource_only_permissions
  local_authentication_disabled   = var.local_authentication_disabled
  sku                             = var.log_analytics_sku
  retention_in_days               = var.retention_in_days
  daily_quota_gb                  = var.daily_quota_gb
  cmk_for_query_forced            = var.cmk_for_query_forced

  dynamic "identity" {
    for_each = var.log_analytics_identity != null ? [var.log_analytics_identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  internet_ingestion_enabled              = var.internet_ingestion_enabled
  internet_query_enabled                  = var.internet_query_enabled
  reservation_capacity_in_gb_per_day      = var.reservation_capacity_in_gb_per_day
  data_collection_rule_id                 = var.data_collection_rule_id
  immediate_data_purge_on_30_days_enabled = var.immediate_data_purge_on_30_days_enabled
  tags                                    = var.tags
}
