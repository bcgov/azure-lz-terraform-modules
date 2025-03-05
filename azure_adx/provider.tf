# This is a temporary provider to allow the creation of the ADX cluster
# This should be removed from the module and the cluster should be deployed via the module
# in the azure-lz-core-{forge,live} repos
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
  subscription_id = "40e13180-2fb8-4399-8931-f0c3eefb3e14"
}

provider "azapi" {
  subscription_id = data.azurerm_subscription.current.subscription_id
}
