terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source                = "Azure/azapi"
      version               = "~> 2.4"
      configuration_aliases = [azapi.connectivity]
    }
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 4.0"
      configuration_aliases = [azurerm.connectivity, azurerm.management]
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
