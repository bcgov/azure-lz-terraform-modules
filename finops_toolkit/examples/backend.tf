terraform {
  backend "azurerm" {
    resource_group_name  = "BCGOV-MGD-LIVE-terraform"
    storage_account_name = "bcgovmgdllivetfstate"
    container_name       = "tfstate"
    key                  = "azure-lz-core-finopstoolkit-live.tfstate"
  }
}
