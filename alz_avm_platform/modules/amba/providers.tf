provider "azapi" {
  alias                      = "management"
  skip_provider_registration = false
  subscription_id            = var.subscription_id_management
}

provider "azurerm" {
  # resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  resource_provider_registrations = "all" # Options: core, extended, all, none. Reference: https://github.com/hashicorp/terraform-provider-azurerm/blob/main/internal/resourceproviders/required.go
  # NOTE: 'all' includes the required resource providers for the AMBA module, including Microsoft.AlertsManagement and Microsoft.Insights.
  alias           = "management"
  subscription_id = var.subscription_id_management
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
