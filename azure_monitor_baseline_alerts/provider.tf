terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.76"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.10"
    }

    alz = {
      source  = "azure/alz"
      version = "~> 0.21"
    }
  }
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id != "" ? var.management_subscription_id : data.azapi_client_config.current.subscription_id
  features {}
}
