# azure_monitor_baseline_alerts

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0 |
| <a name="requirement_alz"></a> [alz](#requirement\_alz) | ~> 0.17 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_amba_alz"></a> [amba\_alz](#module\_amba\_alz) | Azure/avm-ptn-monitoring-amba-alz/azurerm | 0.1.1 |
| <a name="module_amba_policy"></a> [amba\_policy](#module\_amba\_policy) | Azure/avm-ptn-alz/azurerm | 0.12.0 |

## Resources

| Name | Type |
|------|------|
| [azapi_client_config.current](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_arm_role_id"></a> [action\_group\_arm\_role\_id](#input\_action\_group\_arm\_role\_id) | Action group ARM role ID | `list(string)` | `[]` | no |
| <a name="input_action_group_email"></a> [action\_group\_email](#input\_action\_group\_email) | Action group email | `list(string)` | `[]` | no |
| <a name="input_amba_disable_tag_name"></a> [amba\_disable\_tag\_name](#input\_amba\_disable\_tag\_name) | Tag name used to disable monitoring at the resource level. | `string` | `"MonitorDisable"` | no |
| <a name="input_amba_disable_tag_values"></a> [amba\_disable\_tag\_values](#input\_amba\_disable\_tag\_values) | Tag value(s) used to disable monitoring at the resource level. | `list(string)` | <pre>[<br/>  "true",<br/>  "Test",<br/>  "Dev",<br/>  "Sandbox"<br/>]</pre> | no |
| <a name="input_architecture_name"></a> [architecture\_name](#input\_architecture\_name) | The name of the architecture. | `string` | n/a | yes |
| <a name="input_bring_your_own_action_group_resource_id"></a> [bring\_your\_own\_action\_group\_resource\_id](#input\_bring\_your\_own\_action\_group\_resource\_id) | The resource id of the action group, required if you intend to use an existing action group for monitoring purposes. | `list(string)` | `[]` | no |
| <a name="input_bring_your_own_alert_processing_rule_resource_id"></a> [bring\_your\_own\_alert\_processing\_rule\_resource\_id](#input\_bring\_your\_own\_alert\_processing\_rule\_resource\_id) | The resource id of the alert processing rule, required if you intend to use an existing alert processing rule for monitoring purposes. | `string` | `""` | no |
| <a name="input_bring_your_own_user_assigned_managed_identity"></a> [bring\_your\_own\_user\_assigned\_managed\_identity](#input\_bring\_your\_own\_user\_assigned\_managed\_identity) | Flag to indicate if the user-assigned managed identity is provided by the user. | `bool` | `false` | no |
| <a name="input_bring_your_own_user_assigned_managed_identity_resource_id"></a> [bring\_your\_own\_user\_assigned\_managed\_identity\_resource\_id](#input\_bring\_your\_own\_user\_assigned\_managed\_identity\_resource\_id) | The resource ID of the user-assigned managed identity. | `string` | `""` | no |
| <a name="input_event_hub_resource_id"></a> [event\_hub\_resource\_id](#input\_event\_hub\_resource\_id) | The resource ID of the event hub. | `list(string)` | `[]` | no |
| <a name="input_function_resource_id"></a> [function\_resource\_id](#input\_function\_resource\_id) | The resource ID of the Azure function. | `string` | `""` | no |
| <a name="input_function_trigger_uri"></a> [function\_trigger\_uri](#input\_function\_trigger\_uri) | The trigger URI of the Azure function. | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Location | `string` | `"canadacentral"` | no |
| <a name="input_logic_app_callback_url"></a> [logic\_app\_callback\_url](#input\_logic\_app\_callback\_url) | The callback URL of the logic app. | `string` | `""` | no |
| <a name="input_logic_app_resource_id"></a> [logic\_app\_resource\_id](#input\_logic\_app\_resource\_id) | The resource ID of the logic app. | `string` | `""` | no |
| <a name="input_management_subscription_id"></a> [management\_subscription\_id](#input\_management\_subscription\_id) | Management subscription ID | `string` | `""` | no |
| <a name="input_parent_resource_id"></a> [parent\_resource\_id](#input\_parent\_resource\_id) | The parent resource ID for the architecture. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group where the resources will be deployed. | `string` | `"rg-amba-monitoring-001"` | no |
| <a name="input_root_management_group_name"></a> [root\_management\_group\_name](#input\_root\_management\_group\_name) | The name of the root management group. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | <pre>{<br/>  "_deployed_by_amba": "True"<br/>}</pre> | no |
| <a name="input_user_assigned_managed_identity_name"></a> [user\_assigned\_managed\_identity\_name](#input\_user\_assigned\_managed\_identity\_name) | The name of the user-assigned managed identity. | `string` | `"id-amba-prod-001"` | no |
| <a name="input_webhook_service_uri"></a> [webhook\_service\_uri](#input\_webhook\_service\_uri) | The service URI of the webhook. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amba_alz"></a> [amba\_alz](#output\_amba\_alz) | Outputs from the AMBA ALZ module |
| <a name="output_amba_policy"></a> [amba\_policy](#output\_amba\_policy) | Outputs from the AMBA Policy module |
<!-- END_TF_DOCS -->
