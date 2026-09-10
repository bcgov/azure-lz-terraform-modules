#------------------------------------------------------------------------------
# Key Vault
#------------------------------------------------------------------------------

resource "azurerm_key_vault" "this" {
  name                          = "${local.key_vault_name}-${random_string.suffix.result}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.this.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = var.key_vault_sku
  soft_delete_retention_days    = var.key_vault_soft_delete_retention_days
  purge_protection_enabled      = true
  public_network_access_enabled = length(var.allowed_ip_addresses) > 0
  rbac_authorization_enabled    = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_addresses
  }

  tags = local.tags
}

#------------------------------------------------------------------------------
# Key Vault Secrets
#------------------------------------------------------------------------------

# Jira API token
resource "azurerm_key_vault_secret" "jira_api_token" {
  count = var.enable_alerting ? 1 : 0

  name         = "jira-api-token"
  value        = var.jira_api_token
  key_vault_id = azurerm_key_vault.this.id
  tags         = local.tags

  depends_on = [
    azurerm_role_assignment.terraform_spn_secrets_officer,
    azurerm_role_assignment.cloud_team_secrets_officer,
    azurerm_private_endpoint.keyvault
  ]
}

# Teams webhook URL (stored as secret for Logic App reference)
resource "azurerm_key_vault_secret" "teams_webhook_url" {
  count = var.enable_alerting ? 1 : 0

  name         = "teams-webhook-url"
  value        = var.teams_webhook_url
  key_vault_id = azurerm_key_vault.this.id
  tags         = local.tags

  depends_on = [
    azurerm_role_assignment.terraform_spn_secrets_officer,
    azurerm_role_assignment.cloud_team_secrets_officer,
    azurerm_private_endpoint.keyvault
  ]
}

#------------------------------------------------------------------------------
# Key Vault RBAC Assignments
#------------------------------------------------------------------------------

# Cloud Team - Secrets Officer
resource "azurerm_role_assignment" "cloud_team_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = local.cloud_team_group_id
}

# Terraform SPN - Secrets Officer (for initial secret creation)
resource "azurerm_role_assignment" "terraform_spn_secrets_officer" {
  count = var.terraform_spn_object_id != null ? 1 : 0

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.terraform_spn_object_id
}

# Logic App - Secrets User (for reading Jira token)
resource "azurerm_role_assignment" "logic_app_secrets_user" {
  count = var.enable_alerting ? 1 : 0

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_logic_app_workflow.alert_router[0].identity[0].principal_id
}
