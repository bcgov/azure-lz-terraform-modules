#------------------------------------------------------------------------------
# Terraform Backend Configuration
#------------------------------------------------------------------------------

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstateprod"
    container_name       = "tfstate"
    key                  = "mccs-observability/connectivity.tfstate"
  }
}
