# Get the current client configuration from the AzureRM provider
data "azurerm_client_config" "current" {}

# NOTE: Data lookup for vWAN is used to get the address_prefix for the vWAN Hub, create a security rule for the vWAN Hub, and create a vHub connection
# data "azurerm_virtual_hub" "vwan_hub" {
#   name                = var.virtual_wan_hub_name
#   resource_group_name = var.virtual_wan_hub_resource_group
# }
