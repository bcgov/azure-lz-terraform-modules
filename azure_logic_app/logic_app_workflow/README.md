# logic_app_workflow

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.jira](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_logic_app_workflow.alerts_logic_app_workflow](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_workflow) | resource |
| [azurerm_resource_group.alerts_logic_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_managed_api.jira](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/managed_api) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_connection_display_name"></a> [api\_connection\_display\_name](#input\_api\_connection\_display\_name) | (Optional) A display name for this API Connection. | `string` | `null` | no |
| <a name="input_api_connection_name"></a> [api\_connection\_name](#input\_api\_connection\_name) | (Required) The Name which should be used for this API Connection. | `string` | n/a | yes |
| <a name="input_jira_api_token"></a> [jira\_api\_token](#input\_jira\_api\_token) | (Required) The API token for the Jira API. | `string` | n/a | yes |
| <a name="input_jira_api_username"></a> [jira\_api\_username](#input\_jira\_api\_username) | (Required) The username for the Jira API. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location in which the Logic App will be created. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the Logic App will be created. | `string` | n/a | yes |
| <a name="input_workflow_name"></a> [workflow\_name](#input\_workflow\_name) | The name of the Logic App workflow. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_logic_app_id"></a> [logic\_app\_id](#output\_logic\_app\_id) | The ID of the Logic App. |
| <a name="output_workflow"></a> [workflow](#output\_workflow) | The Logic App Workflow object. |
<!-- END_TF_DOCS -->
