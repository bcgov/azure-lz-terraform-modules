terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}
