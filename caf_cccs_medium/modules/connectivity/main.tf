# Configure Terraform to set the required AzureRM provider
# version and features{} block

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.13, != 1.13.0"
    }
  }
}

# Get the current client configuration from the AzureRM provider

data "azurerm_client_config" "current" {}

# Declare the Azure landing zones Terraform module
# and provide the connectivity configuration

module "alz" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.3.1"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  # Base module configuration settings
  root_parent_id   = var.root_parent_id
  root_id          = var.root_id
  default_location = var.primary_location

  # Disable creation of the core management group hierarchy
  # as this is being created by the core module instance
  deploy_core_landing_zones = false

  # Configuration settings for connectivity resources
  deploy_connectivity_resources    = true
  configure_connectivity_resources = local.configure_connectivity_resources
  subscription_id_connectivity     = var.subscription_id_connectivity

}

resource "azapi_update_resource" "vnet_link_resolution_policy" {
  for_each = module.alz.azurerm_private_dns_zone_virtual_network_link.connectivity

  type        = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01"
  resource_id = each.value.id

  body = {
    properties = {
      resolutionPolicy = var.private_dns_resolution_policy
    }
  }

  depends_on = [module.alz]
}
