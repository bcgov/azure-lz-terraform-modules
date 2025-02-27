# key-vault

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.ENGINE-ID](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.ENGINE-SECRET](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.IDENTITY-ID](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.TENANT-ID](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.UI-ID](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_role_assignment.keyVaultSecretsOfficer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.keyVaultUser](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_role_definition.keyVaultSecretsOfficer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |
| [azurerm_role_definition.keyVaultUser](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |
| [azurerm_subscription.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_engineAppId"></a> [engineAppId](#input\_engineAppId) | IPAM-Engine App Registration Client/App ID | `string` | n/a | yes |
| <a name="input_engineAppSecret"></a> [engineAppSecret](#input\_engineAppSecret) | IPAM-Engine App Registration Client Secret | `string` | n/a | yes |
| <a name="input_identityClientId"></a> [identityClientId](#input\_identityClientId) | Managed Identity ClientId | `string` | n/a | yes |
| <a name="input_identityPrincipalId"></a> [identityPrincipalId](#input\_identityPrincipalId) | Managed Identity Id | `string` | n/a | yes |
| <a name="input_keyVaultName"></a> [keyVaultName](#input\_keyVaultName) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | n/a | `string` | n/a | yes |
| <a name="input_uiAppId"></a> [uiAppId](#input\_uiAppId) | IPAM-UI App Registration Client/App ID | `string` | n/a | yes |
| <a name="input_workspaceId"></a> [workspaceId](#input\_workspaceId) | Log Analytics Worskpace ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | n/a |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | n/a |
<!-- END_TF_DOCS -->
