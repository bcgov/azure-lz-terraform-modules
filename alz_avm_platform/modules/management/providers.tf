provider "azapi" {
  alias                      = "management"
  skip_provider_registration = true
  subscription_id            = var.subscription_id_management
}

provider "azurerm" {
  resource_provider_registrations = "none"
  alias                           = "management"
  subscription_id                 = var.subscription_id_management
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
