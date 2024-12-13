# cosmos

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [azurerm_cosmosdb_account.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_sql_container.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container) | resource |
| [azurerm_cosmosdb_sql_database.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [azurerm_cosmosdb_sql_role_assignment.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_role_assignment) | resource |
| [azurerm_monitor_diagnostic_setting.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cosmosAccountName"></a> [cosmosAccountName](#input\_cosmosAccountName) | CosmosDB Account Name | `string` | n/a | yes |
| <a name="input_cosmosContainerName"></a> [cosmosContainerName](#input\_cosmosContainerName) | CosmosDB Container Name | `string` | n/a | yes |
| <a name="input_cosmosDatabaseName"></a> [cosmosDatabaseName](#input\_cosmosDatabaseName) | CosmosDB Database Name | `string` | n/a | yes |
| <a name="input_keyVaultName"></a> [keyVaultName](#input\_keyVaultName) | KeyVault Name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Deployment Location | `string` | n/a | yes |
| <a name="input_principalId"></a> [principalId](#input\_principalId) | Managed Identity PrincipalId | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | n/a | `string` | n/a | yes |
| <a name="input_workspaceId"></a> [workspaceId](#input\_workspaceId) | Log Analytics Workspace ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cosmosDocumentEndpoint"></a> [cosmosDocumentEndpoint](#output\_cosmosDocumentEndpoint) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
