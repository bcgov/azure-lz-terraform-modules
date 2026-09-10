terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.76"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.10" # NOTE: Cannot use v2.x if calling this module from the CAF deployment
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}

  alias           = "connectivity"
  subscription_id = var.subscription_id_connectivity
}
