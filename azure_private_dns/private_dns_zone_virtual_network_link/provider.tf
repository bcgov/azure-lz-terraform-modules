terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  use_oidc = true
  features {}

  alias           = "connectivity"
  subscription_id = var.subscription_id_connectivity
}
