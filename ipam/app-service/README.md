# app-service

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
| [azurerm_linux_web_app.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_monitor_diagnostic_setting.ipam-service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.ipam-service-plan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_service_plan.ipam](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_appServiceName"></a> [appServiceName](#input\_appServiceName) | App Service Name | `string` | n/a | yes |
| <a name="input_appServicePlanName"></a> [appServicePlanName](#input\_appServicePlanName) | App Service Plan Name | `string` | n/a | yes |
| <a name="input_azureCloud"></a> [azureCloud](#input\_azureCloud) | Azure Cloud Enviroment | `string` | `"AZURE_PUBLIC"` | no |
| <a name="input_containerName"></a> [containerName](#input\_containerName) | CosmosDB Container Name | `string` | n/a | yes |
| <a name="input_cosmosDbUri"></a> [cosmosDbUri](#input\_cosmosDbUri) | CosmosDB URI | `string` | n/a | yes |
| <a name="input_databaseName"></a> [databaseName](#input\_databaseName) | CosmosDB Database Name | `string` | n/a | yes |
| <a name="input_deployAsContainer"></a> [deployAsContainer](#input\_deployAsContainer) | Flag to Deploy IPAM as a Container | `bool` | `false` | no |
| <a name="input_keyVaultUri"></a> [keyVaultUri](#input\_keyVaultUri) | KeyVault URI | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Deployment Location | `string` | n/a | yes |
| <a name="input_managedIdentityClientId"></a> [managedIdentityClientId](#input\_managedIdentityClientId) | Managed Identity ClientId | `string` | n/a | yes |
| <a name="input_managedIdentityId"></a> [managedIdentityId](#input\_managedIdentityId) | Managed Identity Id | `string` | n/a | yes |
| <a name="input_privateAcr"></a> [privateAcr](#input\_privateAcr) | Flag to Deploy Private Container Registry | `bool` | `false` | no |
| <a name="input_privateAcrUri"></a> [privateAcrUri](#input\_privateAcrUri) | Uri for Private Container Registry | `string` | n/a | yes |
| <a name="input_resourceGroupName"></a> [resourceGroupName](#input\_resourceGroupName) | n/a | `string` | n/a | yes |
| <a name="input_workspaceId"></a> [workspaceId](#input\_workspaceId) | Log Analytics Worskpace ID | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
