terraform {
  required_version = ">=1.8.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.112.0, < 4.0.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 1.13"
    }

    azureipam = {
      source  = "XtratusCloud/azureipam"
      version = "1.0.1"
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
}

provider "azureipam" {
  api_url = "https://ipam-forge.azurewebsites.net"
  token   = var.IPAM_TOKEN
}
