terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.112.0, < 4.0.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 1.13, != 1.13.0"
    }
  }
}

# provider "azurerm" {
#   use_oidc = true
#   features {}

#   subscription_id = var.subscription_id_connectivity
# }

# provider "azapi" {
#   # More information on the authentication methods supported by
#   # the AzureRM Provider can be found here:
#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

#   # subscription_id = "..."
#   # client_id       = "..."
#   # client_secret   = "..."
#   # tenant_id       = "..."
# }
