
module "avm-ptn-alz-management" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.9.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  providers = {
    azurerm = azurerm.management
  }

  # Required Variables
  automation_account_name = var.automation_account_name
  location                = var.location
  resource_group_name     = var.resource_group_name

  # Optional Variables
  automation_account_encryption                              = var.automation_account_encryption
  automation_account_identity                                = var.automation_account_identity
  automation_account_local_authentication_enabled            = var.automation_account_local_authentication_enabled
  automation_account_location                                = var.automation_account_location
  automation_account_public_network_access_enabled           = var.automation_account_public_network_access_enabled
  automation_account_sku_name                                = var.automation_account_sku_name
  data_collection_rules                                      = var.data_collection_rules
  enable_telemetry                                           = var.enable_telemetry
  linked_automation_account_creation_enabled                 = var.linked_automation_account_creation_enabled
  log_analytics_solution_plans                               = var.log_analytics_solution_plans
  log_analytics_workspace_allow_resource_only_permissions    = var.log_analytics_workspace_allow_resource_only_permissions
  log_analytics_workspace_cmk_for_query_forced               = var.log_analytics_workspace_cmk_for_query_forced
  log_analytics_workspace_creation_enabled                   = var.log_analytics_workspace_creation_enabled
  log_analytics_workspace_daily_quota_gb                     = var.log_analytics_workspace_daily_quota_gb
  log_analytics_workspace_id                                 = var.log_analytics_workspace_id
  log_analytics_workspace_internet_ingestion_enabled         = var.log_analytics_workspace_internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled             = var.log_analytics_workspace_internet_query_enabled
  log_analytics_workspace_local_authentication_enabled       = var.log_analytics_workspace_local_authentication_enabled
  log_analytics_workspace_name                               = var.log_analytics_workspace_name
  log_analytics_workspace_reservation_capacity_in_gb_per_day = var.log_analytics_workspace_reservation_capacity_in_gb_per_day
  log_analytics_workspace_retention_in_days                  = var.log_analytics_workspace_retention_in_days
  log_analytics_workspace_sku                                = var.log_analytics_workspace_sku
  resource_group_creation_enabled                            = var.resource_group_creation_enabled
  sentinel_onboarding                                        = var.sentinel_onboarding
  tags                                                       = var.tags
  timeouts                                                   = var.timeouts
  user_assigned_managed_identities                           = var.user_assigned_managed_identities
}
