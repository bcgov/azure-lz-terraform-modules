variable "keyVaultName" {
  type = string
}
variable "location" {
  type = string
}
variable "resourceGroupName" {
  type = string
}
variable "uiAppId" {
  description = "IPAM-UI App Registration Client/App ID"
  type        = string
}

variable "engineAppId" {
  description = "IPAM-Engine App Registration Client/App ID"
  type        = string
}
variable "engineAppSecret" {
  description = "IPAM-Engine App Registration Client Secret"
  type        = string
}
variable "identityPrincipalId" {
  description = "Managed Identity Id"
  type        = string
}

variable "identityClientId" {
  description = "Managed Identity ClientId"
  type        = string
}
variable "workspaceId" {
  description = "Log Analytics Worskpace ID"
  type        = string
}
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "ipam" {
  name                      = var.keyVaultName
  location                  = var.location
  resource_group_name       = var.resourceGroupName
  purge_protection_enabled  = true
  enable_rbac_authorization = true
  tenant_id                 = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
data "azurerm_subscription" "ipam" {
}
data "azurerm_role_definition" "keyVaultUser" {
  role_definition_id = "4633458b-17de-408a-b874-0445c86b69e6"
  scope              = data.azurerm_subscription.ipam.id # /subscriptions/00000000-0000-0000-0000-000000000000
}
resource "azurerm_role_assignment" "keyVaultUser" {
  scope              = azurerm_key_vault.ipam.id
  principal_type     = "ServicePrincipal"
  role_definition_id = data.azurerm_role_definition.keyVaultUser.id
  principal_id       = var.identityPrincipalId
}
data "azurerm_role_definition" "keyVaultSecretsOfficer" {
  role_definition_id = "b86a8fe4-44ce-4948-aee5-eccb2c155cd7"
  scope              = data.azurerm_subscription.ipam.id # /subscriptions/00000000-0000-0000-0000-000000000000
}
# Assing access to terraform runner to write secrets to Vault
resource "azurerm_role_assignment" "keyVaultSecretsOfficer" {
  scope              = azurerm_key_vault.ipam.id
  principal_type     = "ServicePrincipal"
  role_definition_id = data.azurerm_role_definition.keyVaultSecretsOfficer.id
  principal_id       = data.azurerm_client_config.current.object_id
}
resource "azurerm_key_vault_secret" "IDENTITY-ID" {
  name         = "IDENTITY-ID"
  value        = var.identityClientId
  key_vault_id = resource.azurerm_key_vault.ipam.id
}

resource "azurerm_key_vault_secret" "TENANT-ID" {
  name         = "TENANT-ID"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = resource.azurerm_key_vault.ipam.id
}

resource "azurerm_key_vault_secret" "UI-ID" {
  name         = "UI-ID"
  value        = var.uiAppId
  key_vault_id = resource.azurerm_key_vault.ipam.id
}
resource "azurerm_key_vault_secret" "ENGINE-ID" {
  name         = "ENGINE-ID"
  value        = var.engineAppId
  key_vault_id = resource.azurerm_key_vault.ipam.id
}
resource "azurerm_key_vault_secret" "ENGINE-SECRET" {
  name         = "ENGINE-SECRET"
  value        = var.engineAppSecret
  key_vault_id = resource.azurerm_key_vault.ipam.id
}
output "key_vault_id" {
  value = resource.azurerm_key_vault.ipam.id
}

output "key_vault_uri" {
  value = resource.azurerm_key_vault.ipam.vault_uri
}
