terraform {
  required_version = ">=1.8.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.112.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}

  subscription_id = var.subscription_id_connectivity
}
