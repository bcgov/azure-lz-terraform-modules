provider "azurerm" {
  alias           = "management"
  subscription_id = var.subscription_id_management
  features {}
}
