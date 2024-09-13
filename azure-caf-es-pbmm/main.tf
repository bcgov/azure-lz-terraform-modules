# Configure Terraform to set the required AzureRM provider
# version and features{} block

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.108.0"
    }
  }
}

# Define the provider configuration

provider "azurerm" {
  features {}
}

# Get the current client configuration from the AzureRM provider

data "azurerm_client_config" "current" {}

# Logic to handle 1-3 platform subscriptions as available

locals {
  subscription_id_connectivity = coalesce(var.subscription_id_connectivity, local.subscription_id_management)
  subscription_id_identity     = coalesce(var.subscription_id_identity, local.subscription_id_management)
  subscription_id_management   = coalesce(var.subscription_id_management, data.azurerm_client_config.current.subscription_id)
  root_parent_id               = coalesce(var.root_parent_id, data.azurerm_client_config.current.tenant_id)
}

# The following module declarations act to orchestrate the
# independently defined module instances for core,
# connectivity and management resources

module "connectivity" {
  source = "./modules/connectivity"

  configure_connectivity_resources = var.configure_connectivity_resources
  connectivity_resources_tags      = var.connectivity_resources_tags
  enable_ddos_protection           = var.enable_ddos_protection
  primary_location                 = var.primary_location
  secondary_location               = var.secondary_location
  root_parent_id                   = local.root_parent_id
  root_id                          = var.root_id
  subscription_id_connectivity     = local.subscription_id_connectivity
}

module "management" {
  source = "./modules/management"

  configure_management_resources = var.configure_management_resources
  email_security_contact         = var.email_security_contact
  log_retention_in_days          = var.log_retention_in_days
  management_resources_tags      = var.management_resources_tags
  primary_location               = var.primary_location
  root_parent_id                 = local.root_parent_id
  root_id                        = var.root_id
  subscription_id_management     = local.subscription_id_management
}

module "core" {
  source = "./modules/core"

  configure_identity_resources     = var.configure_identity_resources
  configure_connectivity_resources = module.connectivity.configuration
  configure_management_resources   = module.management.configuration
  primary_location                 = var.primary_location
  secondary_location               = var.secondary_location
  root_parent_id                   = local.root_parent_id
  root_id                          = var.root_id
  root_name                        = var.root_name
  subscription_id_connectivity     = local.subscription_id_connectivity
  subscription_id_identity         = local.subscription_id_identity
  subscription_id_management       = local.subscription_id_management
  archetype_config_overrides       = var.archetype_config_overrides
}
