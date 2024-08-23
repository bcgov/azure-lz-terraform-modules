variable "managedIdentityName" {
  type = string
}
variable "location" {
  type = string
}
variable "resourceGroupName" {
  type = string
}
variable "resourceGroupId" {
  type = string
}
resource "azurerm_user_assigned_identity" "ipam" {
  name                = var.managedIdentityName
  location            = var.location
  resource_group_name = var.resourceGroupName
}
data "azurerm_subscription" "ipam" {
}
data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
  scope              = data.azurerm_subscription.ipam.id # /subscriptions/00000000-0000-0000-0000-000000000000
}

data "azurerm_role_definition" "managed-identity-operator" {
  role_definition_id = "f1a07417-d97a-45cb-824c-7a7467783830"
  scope              = data.azurerm_subscription.ipam.id # /subscriptions/00000000-0000-0000-0000-000000000000
}

resource "azurerm_role_assignment" "contributor" {
  scope              = var.resourceGroupId
  principal_type     = "ServicePrincipal"
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = resource.azurerm_user_assigned_identity.ipam.principal_id
}

resource "azurerm_role_assignment" "managed-identity-operator" {
  scope              = var.resourceGroupId
  principal_type     = "ServicePrincipal"
  role_definition_id = data.azurerm_role_definition.managed-identity-operator.id
  principal_id       = resource.azurerm_user_assigned_identity.ipam.principal_id
}
output "managedIdentity" {
  value = {
    id : resource.azurerm_user_assigned_identity.ipam.id
    client_id : resource.azurerm_user_assigned_identity.ipam.client_id
    principal_id : resource.azurerm_user_assigned_identity.ipam.principal_id
  }
}
