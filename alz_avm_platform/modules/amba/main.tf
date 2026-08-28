module "amba" {
  source  = "Azure/avm-ptn-monitoring-amba-alz/azurerm"
  version = "0.4.0"

  providers = {
    azurerm = azurerm.management
    azapi   = azapi.management
  }

  # Required parameters
  location                   = var.location
  root_management_group_name = local.root_management_group_name

  # Optional parameters
  resource_group_name = var.amba_resource_group_name
  # tags                                = var.tags # IMPORTANT: Do not include tags in the AMBA module, as it will overwrite the tags on the resource group and all resources created by the module, which are used for remediation, etc.
  user_assigned_managed_identity_name = var.amba_user_assigned_managed_identity_name
}
