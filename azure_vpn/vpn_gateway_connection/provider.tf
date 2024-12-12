provider "azurerm" {
  use_oidc = true
  features {}
  # NOTE: The assumption is that the pipeline will be using the Management subscription for the base provider
  # The sub-modules will be using the subscription_id_connectivity
  subscription_id = var.subscription_id_connectivity
}
