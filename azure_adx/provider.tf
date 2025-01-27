terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.12.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "69946426-ca72-4a14-a79f-1cf558067722"
}

provider "azapi" {
  subscription_id = data.azurerm_subscription.current.subscription_id
}
