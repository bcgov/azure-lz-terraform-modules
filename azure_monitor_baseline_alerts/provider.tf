terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.2"
    }

    alz = {
      source  = "azure/alz"
      version = "~> 0.17"
    }
  }
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.management_subscription_id != "" ? var.management_subscription_id : data.azapi_client_config.current.subscription_id
  features {}
}

provider "azapi" {
  skip_provider_registration = false
}

provider "alz" {
  library_overwrite_enabled = true
  library_references = [
    {
      path = "platform/amba"
      ref  = "2025.04.0"
    },
    {
      custom_url = "${path.root}/lib"
    }
  ]
}
