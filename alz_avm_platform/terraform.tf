terraform {
  required_version = "~> 1.12, < 2.0"

  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 4.0"
      configuration_aliases = [azurerm.connectivity, azurerm.management]
    }
    alz = {
      source  = "Azure/alz"
      version = "~> 0.21"
    }
    azapi = {
      source                = "Azure/azapi"
      version               = "~> 2.4"
      configuration_aliases = [azapi.connectivity, azapi.management]
    }
  }
}
