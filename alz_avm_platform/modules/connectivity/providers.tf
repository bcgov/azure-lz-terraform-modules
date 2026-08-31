provider "azapi" {
  alias                      = "connectivity"
  skip_provider_registration = false
  subscription_id            = var.subscription_id_connectivity
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.subscription_id_connectivity
  features {}
}
