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

    # fabric = {
    #   source  = "microsoft/fabric"
    #   version = "~> 1.0"
    # }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}

  subscription_id = var.subscription_id_management
}

provider "azapi" {
  skip_provider_registration = false
}

provider "azureipam" {
  api_url = local.api_url
  token   = var.IPAM_TOKEN
}

# provider "fabric" {
#   # Configuration options
# }
