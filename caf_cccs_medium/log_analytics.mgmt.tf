module "law" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_log_analytics/log_analytics_workspace?ref=v0.0.30"
  source = "../azure_log_analytics/log_analytics_workspace" # For local testing only

  providers = {
    azurerm = azurerm.management
  }
  
  resource_group_name                     = var.log_analytics_resource_group_name
  location                                = var.primary_location
  log_analytics_workspace_name            = var.log_analytics_workspace_name
  allow_resource_only_permissions         = var.allow_resource_only_permissions
  local_authentication_disabled           = var.local_authentication_disabled
  log_analytics_sku                       = var.log_analytics_sku
  retention_in_days                       = var.retention_in_days
  daily_quota_gb                          = var.daily_quota_gb
  cmk_for_query_forced                    = var.cmk_for_query_forced
  log_analytics_identity                  = var.log_analytics_identity
  internet_ingestion_enabled              = var.internet_ingestion_enabled
  internet_query_enabled                  = var.internet_query_enabled
  reservation_capacity_in_gb_per_day      = var.reservation_capacity_in_gb_per_day
  data_collection_rule_id                 = var.data_collection_rule_id
  immediate_data_purge_on_30_days_enabled = var.immediate_data_purge_on_30_days_enabled
}
