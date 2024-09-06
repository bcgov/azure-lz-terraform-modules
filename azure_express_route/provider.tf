terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.112.0, < 4.0.0"
    }

    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
  # NOTE: The assumption is that the pipeline will be using the Management subscription for the base provider
  # The sub-modules will be using the subscription_id_connectivity
}
