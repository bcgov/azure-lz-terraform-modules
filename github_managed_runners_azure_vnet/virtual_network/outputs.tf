output "resource_group_id" {
  description = "The Resource Group ID where the GitHub Runners VNet is deployed."
  value = azurerm_resource_group.ghrunners.id
}
output "subnet_id" {
  description = "The subnet ID for GitHub Runners delegated subnet. This is used by the GitHub Network Settings object for Service Association Links."
  value = azurerm_virtual_network.ghrunners_vnet.subnet["github-runners"].id
}
