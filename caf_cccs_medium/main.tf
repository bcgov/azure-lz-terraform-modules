# Configure Terraform to set the required AzureRM provider
# version and features{} block

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "3.116.0"
      configuration_aliases = [azurerm.connectivity, azurerm.management]
    }

    assert = {
      source  = "hashicorp/assert"
      version = "~> 0.16.0"
    }
  }
}

# Get the current client configuration from the AzureRM provider

data "azurerm_client_config" "current" {}


# The following module declarations act to orchestrate the
# independently defined module instances for core,
# connectivity and management resources

module "connectivity" {
  source = "./modules/connectivity"

  providers = {
    azurerm = azurerm.connectivity
  }

  # NOTE: This is required to ensure the base and LZ firewall policies are created before they are associated with the firewall.
  depends_on = [module.lz_firewall_policy]

  connectivity_resources_tags  = var.connectivity_resources_tags
  enable_ddos_protection       = var.enable_ddos_protection
  primary_location             = var.primary_location
  secondary_location           = var.secondary_location
  root_parent_id               = var.root_parent_id
  root_id                      = var.root_id
  subscription_id_connectivity = var.subscription_id_connectivity

  # NOTE: We cannot use the module.lz_firewall_policy.firewall_policy_id output directly as the CAF module throws the following error:
  # │ Error: Invalid for_each argument
  # │ The "for_each" map includes keys derived from resource attributes that cannot be determined until apply, and so Terraform cannot determine the full set of keys that will identify the instances of this resource.
  # │ When working with unknown values in for_each, it's better to define the map keys statically in your configuration and place apply-time results only in the map values.
  # │ Alternatively, you could use the -target planning option to first apply only the resources that the for_each value depends on, and then apply a second time to fully converge.
  firewall_child_policy_id = format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/firewallPolicies/%s",
    var.subscription_id_connectivity,
    azurerm_resource_group.base_firewall_policy.name,
    var.lz_firewall_policy_name
  )

  vwan_hub_address_prefix = var.vwan_hub_address_prefix
}

module "management" {
  source = "./modules/management"

  providers = {
    azurerm = azurerm.management
  }

  email_security_contact           = var.email_security_contact
  log_retention_in_days            = var.log_retention_in_days
  management_resources_tags        = var.management_resources_tags
  primary_location                 = var.primary_location
  root_parent_id                   = var.root_parent_id
  root_id                          = var.root_id
  subscription_id_management       = var.subscription_id_management
  log_analytics_workspace_settings = var.log_analytics_workspace_settings
}

module "core" {
  source = "./modules/core"

  providers = {
    azurerm = azurerm.management
  }

  configure_connectivity_resources = module.connectivity.configuration
  configure_management_resources   = module.management.configuration
  primary_location                 = var.primary_location
  secondary_location               = var.secondary_location
  country_location                 = var.country_location
  root_parent_id                   = var.root_parent_id
  root_id                          = var.root_id
  root_name                        = var.root_name
  subscription_id_connectivity     = var.subscription_id_connectivity
  subscription_id_identity         = var.subscription_id_identity
  subscription_id_management       = var.subscription_id_management

  policy_effect     = var.policy_effect
  VNet-DNS-Settings = var.VNet-DNS-Settings
}
