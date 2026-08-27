module "management_groups" {
  source = "./modules/management_groups"

  subscription_id_management = var.subscription_id_management

  # Required Configuration
  architecture_name  = var.architecture_name
  location           = var.location
  parent_resource_id = var.parent_resource_id

  policy_default_values = {
    amba_alz_management_subscription_id = jsonencode({
      value = var.subscription_id_management != "" ? var.subscription_id_management : data.azapi_client_config.current.subscription_id
    })
    amba_alz_resource_group_location             = jsonencode({ value = var.location })
    amba_alz_resource_group_name                 = jsonencode({ value = var.amba_resource_group_name })
    amba_alz_user_assigned_managed_identity_name = jsonencode({ value = var.amba_user_assigned_managed_identity_name })
  }

  # policy_assignments_to_modify = var.policy_assignments_to_modify
  policy_assignments_to_modify = {
    bcgov-managed-lz-avm = { # Management Group ID
      policy_assignments = {
        # TESTING: [Preview]: Deploy Microsoft Defender for Endpoint agent (Initiative)
        Deploy-MDEndpoints = { # Policy Assignment Name
          parameters = {
            microsoftDefenderForEndpointWindowsVmAgentDeployEffect = jsonencode({ value = "AuditIfNotExists" })
          }
        },
      }
    }
  }
}

module "amba" {
  source = "./modules/amba"

  subscription_id_management = var.subscription_id_management

  # Required Configuration
  location = var.location

  # Optional Configuration
  amba_resource_group_name                 = var.amba_resource_group_name
  amba_user_assigned_managed_identity_name = var.amba_user_assigned_managed_identity_name
  tags                                     = var.tags
}

module "platform_subscriptions" {
  source = "./modules/platform_subscriptions"

  # Required Configuration
  location               = var.location
  platform_subscriptions = var.platform_subscriptions
}

module "management_resources" {
  source = "./modules/management_resources"

  subscription_id_management = var.subscription_id_management

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
  user_assigned_managed_identities                           = var.user_assigned_managed_identities
}

# module "connectivity" {
#   source  = "./modules/connectivity"
# }
