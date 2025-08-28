terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }

    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.2, < 4.0.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}
  # NOTE: The assumption is that the pipeline will be using the Management subscription for the base provider
  # The sub-modules will be using the subscription_id_connectivity

  # subscription_id is now required with AzureRM provider 4.0. Use either of the following methods:
  # subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  # export ARM_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  subscription_id = var.subscription_id_connectivity
}
