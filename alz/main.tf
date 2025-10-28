# Azure Landing Zone (ALZ) Module
# Using Azure Verified Module for Platform Landing Zone (ALZ)

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0, < 5.0.0"
    }
    alz = {
      source  = "azure/alz"
      version = "~> 0.17, >= 0.17.4"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.0.0, < 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.0.0"
    }
  }
}

# Configure default azurerm provider
provider "azurerm" {
  features {}
  subscription_id = try(var.subscription_ids["management"], var.subscription_id_management)
}

# Process templated architecture definition using templatefile()
locals {
  # Process the template and write to the expected location
  processed_architecture_definition = templatefile("${path.module}/lib/architecture_definitions/bcgov.alz_architecture_definition.yaml.tmpl", {
    root_id           = var.root_id
    root_display_name = var.root_display_name
  })
}

# Process templated architecture definition using external data source
data "external" "architecture_template" {
  program = ["${path.module}/process-template.sh", "${path.module}/lib/architecture_definitions/bcgov.alz_architecture_definition.yaml.tmpl", var.root_id, var.root_display_name, "${path.module}/lib/architecture_definitions/bcgov.alz_architecture_definition.yaml"]
}

# Configure ALZ provider with custom library
provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    {
      custom_url = "${path.module}/lib"
    }
  ]
}

# Configure additional providers for platform landing zone
provider "azurerm" {
  features {}
  alias           = "connectivity"
  subscription_id = try(var.subscription_ids["connectivity"], var.subscription_id_connectivity)
}

provider "azurerm" {
  features {}
  alias           = "management"
  subscription_id = try(var.subscription_ids["management"], var.subscription_id_management)
}

provider "azurerm" {
  features {}
  alias           = "identity"
  subscription_id = try(var.subscription_ids["identity"], var.subscription_id_identity)
}

# Configure azapi provider for connectivity
provider "azapi" {
  alias = "connectivity"
}

# Configure local provider
provider "local" {}

# Azure Verified Module for Platform Landing Zone (ALZ)
module "avm_ptn_alz" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.13.0"

  # Required Configuration
  architecture_name  = var.architecture_name
  parent_resource_id = var.parent_resource_id
  location           = var.location

  # Optional Configuration
  dependencies                 = var.dependencies
  policy_assignments_to_modify = var.policy_assignments_to_modify
}

# Platform Landing Zone Configuration Module
module "config" {
  source = "./modules/config-templating"

  enable_telemetry = var.enable_telemetry

  starter_locations               = var.starter_locations
  subscription_id_connectivity    = try(var.subscription_ids["connectivity"], var.subscription_id_connectivity)
  subscription_id_identity        = try(var.subscription_ids["identity"], var.subscription_id_identity)
  subscription_id_management      = try(var.subscription_ids["management"], var.subscription_id_management)
  subscription_id_security        = try(var.subscription_ids["security"], "")
  root_parent_management_group_id = var.root_parent_management_group_id
  root_id                         = var.root_id
  root_display_name               = var.root_display_name

  custom_replacements = var.custom_replacements

  connectivity_resource_groups        = var.connectivity_resource_groups
  hub_and_spoke_vnet_settings         = var.hub_and_spoke_vnet_settings
  hub_and_spoke_vnet_virtual_networks = var.hub_and_spoke_vnet_virtual_networks
  virtual_wan_settings                = var.virtual_wan_settings
  virtual_wan_virtual_hubs            = var.virtual_wan_virtual_hubs
  management_resource_settings        = var.management_resource_settings
  management_group_settings           = var.management_group_settings
  tags                                = var.tags
}

# Resource Groups Module
module "resource_groups" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  for_each = var.connectivity_resource_groups

  name             = each.value.name
  location         = each.value.location
  enable_telemetry = var.enable_telemetry
  tags             = try(each.value.tags, var.tags)

  providers = {
    azurerm = azurerm.connectivity
  }
}

# Management Resources Module
module "management_resources" {
  source = "./modules/management_resources"

  count = local.management_resources_enabled ? 1 : 0

  enable_telemetry             = var.enable_telemetry
  management_resource_settings = module.config.management_resource_settings
  tags                         = module.config.tags

  providers = {
    azurerm = azurerm.management
  }
}

# Management Groups Module
module "management_groups" {
  source = "./modules/management_groups"

  count = local.management_groups_enabled ? 1 : 0

  enable_telemetry          = var.enable_telemetry
  management_group_settings = module.config.management_group_settings
  dependencies              = local.management_group_dependencies

  depends_on = [data.external.architecture_template]
}

# Hub and Spoke Virtual Network Module
module "hub_and_spoke_vnet" {
  source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm"
  version = "0.12.0"

  count = local.connectivity_hub_and_spoke_vnet_enabled ? 1 : 0

  hub_and_spoke_networks_settings = local.hub_and_spoke_vnet_settings
  hub_virtual_networks            = local.hub_and_spoke_vnet_virtual_networks
  enable_telemetry                = var.enable_telemetry
  tags                            = try(local.hub_and_spoke_vnet_settings.tags, module.config.tags)

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi.connectivity
  }
}

# Virtual WAN Module
module "virtual_wan" {
  source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm"
  version = "0.11.8"

  count = local.connectivity_virtual_wan_enabled ? 1 : 0

  virtual_wan_settings = local.virtual_wan_settings
  virtual_hubs         = local.virtual_wan_virtual_hubs
  enable_telemetry     = var.enable_telemetry
  tags                 = try(local.virtual_wan_settings.tags, module.config.tags)

  providers = {
    azurerm = azurerm.connectivity
  }
}
