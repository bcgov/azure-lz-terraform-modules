module "management_resources" {
  source  = "Azure/avm-ptn-alz-management/azurerm"
  version = "0.9.0"

  providers = {
    azurerm = azurerm.management
  }

  location                     = var.primary_location
  resource_group_name          = var.management_resource_group_name
  automation_account_name      = var.management_automation_account_name
  log_analytics_workspace_name = var.management_log_analytics_workspace_name
  tags                         = var.tags
  enable_telemetry             = var.enable_telemetry
}

module "connectivity_virtual_wan" {
  source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm"
  version = "0.15.0"

  providers = {
    azurerm = azurerm.connectivity
  }

  virtual_wan_settings = var.virtual_wan_settings
  virtual_hubs         = local.effective_virtual_hubs
  tags                 = var.tags
  enable_telemetry     = var.enable_telemetry
}

# Minimal identity/security subscription bootstrap to anchor dedicated platform subscriptions.
resource "azurerm_resource_group" "identity_bootstrap" {
  provider = azurerm.identity
  count    = var.create_identity_security_bootstrap_resource_groups ? 1 : 0

  name     = var.identity_bootstrap_resource_group_name
  location = var.primary_location
  tags     = var.tags
}

resource "azurerm_resource_group" "security_bootstrap" {
  provider = azurerm.security
  count    = var.create_identity_security_bootstrap_resource_groups ? 1 : 0

  name     = var.security_bootstrap_resource_group_name
  location = var.primary_location
  tags     = var.tags
}

module "amba_alz" {
  source  = "Azure/avm-ptn-monitoring-amba-alz/azurerm"
  version = "0.1.1"

  providers = {
    azurerm = azurerm.management
  }

  count = var.enable_amba ? 1 : 0

  location                            = var.primary_location
  root_management_group_name          = local.management_group_names.platform
  resource_group_name                 = var.amba_resource_group_name
  user_assigned_managed_identity_name = var.amba_user_assigned_managed_identity_name
  tags                                = var.tags
  enable_telemetry                    = var.enable_telemetry
}

module "alz" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.19.1"

  architecture_name  = var.architecture_name
  location           = var.primary_location
  parent_resource_id = local.parent_resource_id

  subscription_placement          = local.subscription_placement
  policy_default_values           = local.effective_policy_default_values
  policy_assignments_to_modify    = var.policy_assignments_to_modify
  policy_assignments_dependencies = concat([module.management_resources.resource_id], var.policy_assignments_dependencies)
  management_groups_dependencies  = var.management_groups_dependencies

  enable_telemetry = var.enable_telemetry
}
