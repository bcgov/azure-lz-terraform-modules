variable "workspaceName" {
  type = string
}
variable "location" {
  type = string
}
variable "resourceGroupName" {
  type = string
}
resource "azurerm_log_analytics_workspace" "ipam" {
  name                = var.workspaceName
  location            = var.location
  resource_group_name = var.resourceGroupName
  sku                 = "PerGB2018"
}
output "workspaceId" {
  value = resource.azurerm_log_analytics_workspace.ipam.id
}
