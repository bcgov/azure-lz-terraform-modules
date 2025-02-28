# collector_policy

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
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_function_collector_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_function_collector_policy) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_collector_policy_name"></a> [collector\_policy\_name](#input\_collector\_policy\_name) | (Required) Specifies the name which should be used for this Network Function Collector Policy. | `string` | n/a | yes |
| <a name="input_ipfx_emission_destination_types"></a> [ipfx\_emission\_destination\_types](#input\_ipfx\_emission\_destination\_types) | (Required) A list of emission destination types. The only possible value is AzureMonitor. | `list(string)` | <pre>[<br/>  "AzureMonitor"<br/>]</pre> | no |
| <a name="input_ipfx_ingestion_source_resource_ids"></a> [ipfx\_ingestion\_source\_resource\_ids](#input\_ipfx\_ingestion\_source\_resource\_ids) | (Required) A list of ingestion source resource IDs. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the Azure Region where the Network Function Collector Policy should exist. | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | (Required) Specifies the Log Analytics Workspace ID. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_traffic_collector_id"></a> [traffic\_collector\_id](#input\_traffic\_collector\_id) | (Required) Specifies the Azure Traffic Collector ID of the Network Function Collector Policy. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_collector_policy_id"></a> [collector\_policy\_id](#output\_collector\_policy\_id) | The ID of the Network Function Collector Policy. |
| <a name="output_collector_policy_name"></a> [collector\_policy\_name](#output\_collector\_policy\_name) | The name of the Network Function Collector Policy. |
| <a name="output_ipfx_emission"></a> [ipfx\_emission](#output\_ipfx\_emission) | The Emission configuration of the Network Function Collector Policy. |
| <a name="output_ipfx_ingestion"></a> [ipfx\_ingestion](#output\_ipfx\_ingestion) | The Ingestion configuration of the Network Function Collector Policy. |
| <a name="output_monitor_diagnostic_setting"></a> [monitor\_diagnostic\_setting](#output\_monitor\_diagnostic\_setting) | The Diagnostic Setting for the Network Function Collector Policy. |
| <a name="output_traffic_collector_id"></a> [traffic\_collector\_id](#output\_traffic\_collector\_id) | The ID of the Traffic Collector associated with the Network Function Collector Policy. |
<!-- END_TF_DOCS -->
