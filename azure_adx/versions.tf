terraform {
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
