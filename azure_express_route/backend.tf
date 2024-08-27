terraform {
  backend "azurerm" {
    resource_group_name  = "BCGOV-MGD-FORGE-terraform"
    storage_account_name = "bcgovmgdlforgetfstate"
    container_name       = "tfstate"
    key                  = "azure-lz-core-expressroute-forge.tfstate"
  }
}
