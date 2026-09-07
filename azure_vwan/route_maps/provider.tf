terraform {
  required_version = ">=1.9.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81"
    }
  }
}

# No provider block: callers pass azurerm via `providers = { azurerm = azurerm.connectivity }`.
