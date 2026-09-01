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

    # NOTE: Used with the Logic App created for Azure Monitor alert processing into Jira tickets
    # amba_alz_logicapp_resource_id                  = jsonencode({ value = var.logic_app_resource_id })
    # amba_alz_logicapp_callback_url                 = jsonencode({ value = var.logic_app_callback_url })

    log_analytics_workspace_id = jsonencode({ value = provider::azapi::resource_group_resource_id(var.subscription_id_management, var.management_resources_resource_group_name, "Microsoft.OperationalInsights/workspaces", [var.log_analytics_workspace_name]) })
    # TODO Figure out what property is needed to set email_security_contact = "cloud.pathfinder@gov.bc.ca"
    # NOTE: Unable to find documentation for this property. Deduced from existing CAF implementation.
    # `terraform plan` shows this is linked with the bcgov-managed-lz-avm/Deploy-MDFC-Config-H224 policy assignment, and the `emailSecurityContact` parameter.
    # email_security_contact = jsonencode({ value = var.email_security_contact })
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
        Deploy-MDFC-Config-H224 = { # Policy Assignment Name
          parameters = {
            emailSecurityContact = jsonencode({ value = var.email_security_contact })
          }
        }
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
  resource_group_name     = var.management_resources_resource_group_name

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

module "ipam" {
  source = "./modules/ipam"

  subscription_id_management = var.subscription_id_management

  location                      = var.location
  ipam_pool_resource_group_name = var.ipam_pool_resource_group_name
  network_manager_name          = var.network_manager_name
  scope                         = var.scope
  ipam_pool_name                = var.ipam_pool_name
  ipam_pool_display_name        = var.ipam_pool_display_name
  ipam_pool_description         = var.ipam_pool_description
  ipam_pool_address_prefixes    = var.ipam_pool_address_prefixes
}

module "connectivity" {
  source = "./modules/connectivity"

  subscription_id_connectivity = var.subscription_id_connectivity
  location                     = var.location

  vwan_resource_group_name = local.vwan_resource_group_name

  # default_naming_convention = var.default_naming_convention
  # default_naming_convention_sequence = var.default_naming_convention_sequence
  # route_maps = var.route_maps
  # tags = var.tags
  virtual_hubs         = local.virtual_hubs
  virtual_wan_settings = local.virtual_wan_settings
}
