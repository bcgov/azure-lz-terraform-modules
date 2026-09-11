module "management_groups" {
  source = "./modules/management_groups"

  subscription_id_management = var.subscription_id_management

  # Required Configuration
  architecture_name  = var.architecture_name
  location           = var.location
  parent_resource_id = var.parent_resource_id

  policy_default_values        = var.policy_default_values
  policy_assignments_to_modify = var.policy_assignments_to_modify

  platform_subscriptions = var.platform_subscriptions

  # Management Resources Variables
  automation_account_name                  = var.automation_account_name
  management_resources_resource_group_name = var.management_resources_resource_group_name

  # Optional Management Resources Variables
  data_collection_rules                      = var.data_collection_rules
  linked_automation_account_creation_enabled = var.linked_automation_account_creation_enabled
  log_analytics_solution_plans               = var.log_analytics_solution_plans
  log_analytics_workspace_daily_quota_gb     = var.log_analytics_workspace_daily_quota_gb
  log_analytics_workspace_name               = var.log_analytics_workspace_name
  # log_analytics_workspace_reservation_capacity_in_gb_per_day = var.log_analytics_workspace_reservation_capacity_in_gb_per_day
  log_analytics_workspace_retention_in_days = var.log_analytics_workspace_retention_in_days
  log_analytics_workspace_sku               = var.log_analytics_workspace_sku
  # sentinel_onboarding                                        = var.sentinel_onboarding
  user_assigned_managed_identities = var.user_assigned_managed_identities
}

module "amba" { # TODO: Move to some sub-module
  source = "./modules/amba"

  subscription_id_management = var.subscription_id_management

  # Required Configuration
  location = var.location

  # Optional Configuration
  amba_resource_group_name                 = var.amba_resource_group_name
  amba_user_assigned_managed_identity_name = var.amba_user_assigned_managed_identity_name
  tags                                     = var.tags
}

module "connectivity" {
  source = "./modules/connectivity"

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  location = var.location

  vwan_resource_group_name = var.vwan_resource_group_name

  # default_naming_convention = var.default_naming_convention # TODO: Look into how using this affects resource naming
  # default_naming_convention_sequence = var.default_naming_convention_sequence
  # route_maps = var.route_maps
  # tags = var.tags
  virtual_hubs         = var.virtual_hubs
  virtual_wan_settings = var.virtual_wan_settings

  # IPAM Variables
  ipam_pool_resource_group_name = var.ipam_pool_resource_group_name
  network_manager_name          = var.network_manager_name
  scope                         = var.scope
  ipam_pool_name                = var.ipam_pool_name
  ipam_pool_display_name        = var.ipam_pool_display_name
  ipam_pool_description         = var.ipam_pool_description
  ipam_pool_address_prefixes    = var.ipam_pool_address_prefixes
}
