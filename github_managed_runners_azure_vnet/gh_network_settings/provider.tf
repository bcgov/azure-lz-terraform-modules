provider "azurerm" {
  use_oidc = true
  features {}

  subscription_id = var.subscription_id_connectivity
}

provider "azapi" {
  # skip_provider_registration = false
  # enable_preflight           = true
}
