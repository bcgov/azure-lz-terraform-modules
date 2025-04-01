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

    azureipam = {
      source  = "XtratusCloud/azureipam"
      version = "~> 1.0"
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

provider "azureipam" {
  api_url = local.api_url
  token   = var.IPAM_TOKEN
}
