terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.76"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.10"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}

  subscription_id = var.subscription_id_connectivity
}

provider "azapi" {
  skip_provider_registration = false
  enable_preflight           = true
}
