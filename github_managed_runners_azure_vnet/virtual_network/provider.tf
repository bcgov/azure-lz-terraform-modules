provider "azurerm" {
  use_oidc = true
  features {}

  subscription_id = var.subscription_id_connectivity
}

provider "azurerm" {
  use_oidc = true
  features {}
  alias = "management"

  subscription_id = var.subscription_id_management
}
