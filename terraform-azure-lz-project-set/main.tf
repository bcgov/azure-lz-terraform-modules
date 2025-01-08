terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.109.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 1.13.1"
    }
  }
}

data "azurerm_management_group" "landing_zones" {
  name = var.lz_management_group_id
}

# create a management group for the project set
resource "azurerm_management_group" "project_set" {
  name                       = var.license_plate
  display_name               = "${var.license_plate}: ${var.project_set_name}"
  parent_management_group_id = data.azurerm_management_group.landing_zones.id
}

module "lz_vending" {
  source  = "Azure/lz-vending/azurerm"
  version = "4.1.3" # NOTE: When updating this version, please update the respective `resourceproviders_*` modules below

  for_each = var.subscriptions

  # Set the default location for resources
  location = var.primary_location

  # subscription variables
  subscription_alias_enabled = true
  subscription_billing_scope = var.subscription_billing_scope
  subscription_display_name  = "${var.license_plate}-${each.value.name}"
  subscription_alias_name    = "${var.license_plate}-${each.value.name}"
  subscription_workload      = "Production"
  subscription_tags          = each.value.tags

  network_watcher_resource_group_enabled = true

  # management group association variables
  subscription_management_group_association_enabled = true
  subscription_management_group_id                  = var.license_plate

  # virtual network variables
  virtual_network_enabled = each.value.network.enabled
  virtual_networks = each.value.network.enabled ? {    
    vwan_spoke = {
      name                        = "${var.license_plate}-${each.value.name}-vwan-spoke"
      address_space               = each.value.network.address_space
      resource_group_name         = "${var.license_plate}-${each.value.name}-networking"
      resource_group_lock_enabled = false
      vwan_connection_enabled     = true
      vwan_hub_resource_id        = var.vwan_hub_resource_id
      vwan_security_configuration = {
        secure_internet_traffic = true
        routing_intent_enabled  = true
      }
      dns_servers = try(each.value.network.dns_servers, null)
      tags        = var.common_tags
    }
  } : {}
}

# Create budgets directly using azurerm provider instead of the lz-vending module
resource "azurerm_consumption_budget_subscription" "subscription_budget" {
  for_each = {
    for k, v in var.subscriptions : k => v
    if v.budget >= 1.00
  }

  name            = "budget-for-${var.license_plate}-${each.value.name}-from-product-registry"
  subscription_id = module.lz_vending[each.key].subscription_resource_id

  amount     = each.value.budget
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
  }

  notification {
    enabled        = each.value.budget > 0
    threshold      = 80.0
    operator       = "GreaterThanOrEqualTo"
    threshold_type = "Actual"

    contact_roles = ["Owner"]
  }

  notification {
    enabled        = each.value.budget > 0
    threshold      = 100.0
    operator       = "GreaterThan"
    threshold_type = "Forecasted"

    contact_roles = ["Owner"]
  }

  lifecycle {
    ignore_changes = [time_period]
  }
}

# NOTE: This Resource Provider is required when using Azure Monitor Baseline Alerts (AMBA)
module "resourceproviders_alerts_management" {
  source  = "Azure/lz-vending/azurerm//modules/resourceprovider"
  version = "4.1.3" # Should match the lz_vending module version

  for_each = {
    for k, v in var.subscriptions : k => v
  }

  subscription_id = module.lz_vending[each.key].subscription_id

  resource_provider = "Microsoft.AlertsManagement"
}

# NOTE: This Resource Provider is required when using Azure Monitor Baseline Alerts (AMBA)
module "resourceproviders_insights" {
  source  = "Azure/lz-vending/azurerm//modules/resourceprovider"
  version = "4.1.3" # Should match the lz_vending module version

  for_each = {
    for k, v in var.subscriptions : k => v
  }

  subscription_id = module.lz_vending[each.key].subscription_id

  resource_provider = "Microsoft.Insights"
}
