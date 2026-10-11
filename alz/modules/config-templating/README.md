# config-templating

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_regions"></a> [regions](#module\_regions) | Azure/avm-utl-regions/azurerm | 0.5.2 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connectivity_resource_groups"></a> [connectivity\_resource\_groups](#input\_connectivity\_resource\_groups) | A map of resource groups to create. These must be created before the connectivity module is applied.<br/><br/>The following attributes are supported:<br/><br/>  - name: The name of the resource group<br/>  - location: The location of the resource group<br/>  - settings: (Optional) An object, which can include an `enabled` setting value that indicates whether the resource group should be created. | <pre>map(object({<br/>    name     = string<br/>    location = string<br/>    settings = optional(any)<br/>  }))</pre> | `{}` | no |
| <a name="input_custom_replacements"></a> [custom\_replacements](#input\_custom\_replacements) | Custom replacements | <pre>object({<br/>    names                      = optional(map(string), {})<br/>    resource_group_identifiers = optional(map(string), {})<br/>    resource_identifiers       = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry) | Flag to enable/disable telemetry | `bool` | `true` | no |
| <a name="input_hub_and_spoke_vnet_settings"></a> [hub\_and\_spoke\_vnet\_settings](#input\_hub\_and\_spoke\_vnet\_settings) | n/a | `any` | `{}` | no |
| <a name="input_hub_and_spoke_vnet_virtual_networks"></a> [hub\_and\_spoke\_vnet\_virtual\_networks](#input\_hub\_and\_spoke\_vnet\_virtual\_networks) | n/a | `any` | `{}` | no |
| <a name="input_management_group_settings"></a> [management\_group\_settings](#input\_management\_group\_settings) | n/a | `any` | `{}` | no |
| <a name="input_management_resource_settings"></a> [management\_resource\_settings](#input\_management\_resource\_settings) | n/a | `any` | `{}` | no |
| <a name="input_root_display_name"></a> [root\_display\_name](#input\_root\_display\_name) | Display name for the root management group | `string` | `""` | no |
| <a name="input_root_id"></a> [root\_id](#input\_root\_id) | Root management group ID for the ALZ hierarchy | `string` | `""` | no |
| <a name="input_root_parent_management_group_id"></a> [root\_parent\_management\_group\_id](#input\_root\_parent\_management\_group\_id) | This is the id of the management group that the ALZ hierarchy will be nested under, will default to the Tenant Root Group | `string` | `""` | no |
| <a name="input_starter_locations"></a> [starter\_locations](#input\_starter\_locations) | The default for Azure resources. (e.g 'uksouth') | `list(string)` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | value of the subscription id for the Connectivity subscription | `string` | n/a | yes |
| <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity) | value of the subscription id for the Identity subscription | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | value of the subscription id for the Management subscription | `string` | n/a | yes |
| <a name="input_subscription_id_security"></a> [subscription\_id\_security](#input\_subscription\_id\_security) | value of the subscription id for the Security subscription | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags of the resource. | `map(string)` | `null` | no |
| <a name="input_virtual_wan_settings"></a> [virtual\_wan\_settings](#input\_virtual\_wan\_settings) | n/a | `any` | `{}` | no |
| <a name="input_virtual_wan_virtual_hubs"></a> [virtual\_wan\_virtual\_hubs](#input\_virtual\_wan\_virtual\_hubs) | n/a | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connectivity_resource_groups"></a> [connectivity\_resource\_groups](#output\_connectivity\_resource\_groups) | n/a |
| <a name="output_custom_replacements"></a> [custom\_replacements](#output\_custom\_replacements) | n/a |
| <a name="output_hub_and_spoke_vnet_settings"></a> [hub\_and\_spoke\_vnet\_settings](#output\_hub\_and\_spoke\_vnet\_settings) | n/a |
| <a name="output_hub_and_spoke_vnet_virtual_networks"></a> [hub\_and\_spoke\_vnet\_virtual\_networks](#output\_hub\_and\_spoke\_vnet\_virtual\_networks) | n/a |
| <a name="output_management_group_settings"></a> [management\_group\_settings](#output\_management\_group\_settings) | n/a |
| <a name="output_management_resource_settings"></a> [management\_resource\_settings](#output\_management\_resource\_settings) | n/a |
| <a name="output_tags"></a> [tags](#output\_tags) | n/a |
| <a name="output_virtual_wan_settings"></a> [virtual\_wan\_settings](#output\_virtual\_wan\_settings) | n/a |
| <a name="output_virtual_wan_virtual_hubs"></a> [virtual\_wan\_virtual\_hubs](#output\_virtual\_wan\_virtual\_hubs) | n/a |
<!-- END_TF_DOCS -->
