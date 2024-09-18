# Get the current client configuration from the AzureRM provider
data "azurerm_client_config" "current" {}

data "azurerm_firewall_policy" "this" {
  name                = var.firewall_policy_name
  resource_group_name = var.firewall_policy_resource_group_name
}

data "azurerm_resource_group" "this" {
  name = var.firewall_policy_resource_group_name  
}