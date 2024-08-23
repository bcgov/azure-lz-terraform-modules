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
  version = "4.1.3"

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
      name                    = "${var.license_plate}-${each.value.name}-vwan-spoke"
      address_space           = each.value.network.address_space
      resource_group_name     = "${var.license_plate}-${each.value.name}-networking"
      vwan_connection_enabled = true
      vwan_hub_resource_id    = var.vwan_hub_resource_id
      vwan_security_configuration = {
        routing_intent_enabled = true
      }
      dns_servers = try(each.value.network.dns_servers, null)
      tags        = var.common_tags
    }
  } : {}

  # budget_enabled = each.value.budget_amount > 0

  # "/subscriptions/60e89f81-a15c-4d7a-9be3-c3795a33a277/providers/Microsoft.Consumption/budgets/registry"
  # / Api Version "2021-10-01"): PUT
  # https://management.azure.com/subscriptions/60e89f81-a15c-4d7a-9be3-c3795a33a277/providers/Microsoft.Consumption/budgets/registry
  # --------------------------------------------------------------------------------
  # RESPONSE 401: 401 Unauthorized
  # ERROR CODE: RBACAccessDenied
  # --------------------------------------------------------------------------------
  # {
  #   "error": {
  #     "code": "RBACAccessDenied",
  #     "message": "The client does not have authorization to perform action. Request ID: d97e8d78-6829-42f3-b0a8-671f1eb4da7e"
  #   }
  # }
  # --------------------------------------------------------------------------------

  # Disable budgets for now due to RBAC access denied above
  budget_enabled = false

  budgets = each.value.budget_amount > 0 ? {
    registry = {
      amount            = each.value.budget_amount
      time_grain        = "Monthly"
      time_period_start = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp())
      time_period_end   = formatdate("YYYY-MM-01'T'00:00:00Z", timeadd(timestamp(), "87600h")) // 10 years from now
      notifications = {
        eightypercent = {
          enabled        = true
          operator       = "GreaterThan"
          threshold      = 80
          threshold_type = "Actual"
          contact_groups = ["Owner"]
        }
        budgetexceeded = {
          enabled        = true
          operator       = "GreaterThan"
          threshold      = 100
          threshold_type = "Forecasted"
          contact_groups = ["Owner"]
        }
      }
    }
  } : {}
}
