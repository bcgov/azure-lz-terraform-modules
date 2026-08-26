terraform {
  backend "azurerm" {
    resource_group_name  = "bcgov-mgd-avm-terraform"
    storage_account_name = "bcgovmgdlavmtfstate"
    subscription_id      = "7eaf8022-ff10-43bd-851b-54c11c0fb515"
    container_name       = "tfstate"
    key                  = "azure-lz-core-avm.tfstate"
  }
}
