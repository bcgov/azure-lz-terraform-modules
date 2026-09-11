provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.subscription_id_connectivity
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.subscription_id_management
  features {}
}

provider "azapi" {
  alias                      = "connectivity"
  skip_provider_registration = false
  subscription_id            = var.subscription_id_connectivity
}

provider "azapi" {
  alias                      = "management"
  skip_provider_registration = false
  subscription_id            = var.subscription_id_management
}
