terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.112.0, < 4.0.0"
      # configuration_aliases = [azurerm.connectivity]
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0, != 1.13.0" # NOTE: Cannot use v2.x if calling this module from the CAF deployment
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}

  subscription_id = var.subscription_id_connectivity
}
