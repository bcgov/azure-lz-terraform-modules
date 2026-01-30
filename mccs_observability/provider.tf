provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id_connectivity
}

provider "azurerm" {
  alias = "management"
  features {}
  subscription_id = var.subscription_id_management
}
