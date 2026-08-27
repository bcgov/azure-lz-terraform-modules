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
  resource_group_name                 = var.amba_resource_group_name
  tags                                = var.tags
  user_assigned_managed_identity_name = var.amba_user_assigned_managed_identity_name
}
