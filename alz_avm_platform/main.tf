module "management_groups" {
  source = "./modules/management_groups"

  subscription_id_management = local.subscription_id_management

  # Required Configuration
  architecture_name  = local.architecture_name
  location           = local.location
  parent_resource_id = local.parent_resource_id

  policy_default_values        = local.policy_default_values
  policy_assignments_to_modify = local.policy_assignments_to_modify

  platform_subscriptions = local.platform_subscriptions

  # Management Resources Variables
  automation_account_name                  = local.automation_account_name
  management_resources_resource_group_name = local.management_resources_resource_group_name

  # Optional Management Resources Variables
  data_collection_rules                      = local.data_collection_rules
  linked_automation_account_creation_enabled = local.linked_automation_account_creation_enabled
  log_analytics_solution_plans               = local.log_analytics_solution_plans
  log_analytics_workspace_daily_quota_gb     = local.log_analytics_workspace_daily_quota_gb
  log_analytics_workspace_name               = local.log_analytics_workspace_name
  # log_analytics_workspace_reservation_capacity_in_gb_per_day = local.log_analytics_workspace_reservation_capacity_in_gb_per_day
  log_analytics_workspace_retention_in_days = local.log_analytics_workspace_retention_in_days
  log_analytics_workspace_sku               = local.log_analytics_workspace_sku
  # sentinel_onboarding                                        = local.sentinel_onboarding
  user_assigned_managed_identities = local.user_assigned_managed_identities
}

module "amba" { # TODO: Move to some sub-module
  source = "./modules/amba"

  subscription_id_management = local.subscription_id_management

  # Required Configuration
  location = local.location

  # Optional Configuration
  amba_resource_group_name                 = local.amba_resource_group_name
  amba_user_assigned_managed_identity_name = local.amba_user_assigned_managed_identity_name
  tags                                     = local.tags
}

module "connectivity" {
  source = "./modules/connectivity"

  subscription_id_connectivity = local.subscription_id_connectivity
  subscription_id_management   = local.subscription_id_management

  location = local.location

  vwan_resource_group_name = local.vwan_resource_group_name

  # default_naming_convention = local.default_naming_convention # TODO: Look into how using this affects resource naming
  # default_naming_convention_sequence = local.default_naming_convention_sequence
  # route_maps = local.route_maps
  # tags = local.tags
  virtual_hubs         = local.virtual_hubs
  virtual_wan_settings = local.virtual_wan_settings

  # IPAM Variables
  ipam_pool_resource_group_name = local.ipam_pool_resource_group_name
  network_manager_name          = local.network_manager_name
  scope                         = local.scope
  ipam_pool_name                = local.ipam_pool_name
  ipam_pool_display_name        = local.ipam_pool_display_name
  ipam_pool_description         = local.ipam_pool_description
  ipam_pool_address_prefixes    = local.ipam_pool_address_prefixes
}
