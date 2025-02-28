# azure_traffic_collector

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
| [azurerm_network_function_azure_traffic_collector.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_function_azure_traffic_collector) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_collector_name"></a> [collector\_name](#input\_collector\_name) | (Required) Specifies the name which should be used for this Network Function Azure Traffic Collector. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Specifies the Azure Region where the Network Function Azure Traffic Collector should exist. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Specifies the name of the Resource Group where the Network Function Azure Traffic Collector should exist. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to the Network Function Azure Traffic Collector. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_collector_id"></a> [collector\_id](#output\_collector\_id) | The ID of the Network Function Azure Traffic Collector. |
| <a name="output_collector_name"></a> [collector\_name](#output\_collector\_name) | The name of the Network Function Azure Traffic Collector. |
| <a name="output_collector_policy_ids"></a> [collector\_policy\_ids](#output\_collector\_policy\_ids) | The IDs of the Network Function Azure Traffic Collector Policies associated with this Network Function Azure Traffic Collector. |
| <a name="output_collector_virtual_hub_id"></a> [collector\_virtual\_hub\_id](#output\_collector\_virtual\_hub\_id) | The ID of the Virtual Hub associated with this Network Function Azure Traffic Collector. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the Resource Group in which the Network Function Azure Traffic Collector is created. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group in which the Network Function Azure Traffic Collector is created. |
<!-- END_TF_DOCS -->
