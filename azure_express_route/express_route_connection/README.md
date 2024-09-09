# express_route_connection

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
| [azurerm_express_route_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_connection) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_key"></a> [authorization\_key](#input\_authorization\_key) | (Optional) The authorization key to establish the Express Route Connection. | `string` | `null` | no |
| <a name="input_circuit_peering_type"></a> [circuit\_peering\_type](#input\_circuit\_peering\_type) | (Required) The type of the Express Route Circuit Peering. | `string` | n/a | yes |
| <a name="input_enable_internet_security"></a> [enable\_internet\_security](#input\_enable\_internet\_security) | (Optional) Is Internet security enabled for this Express Route Connection? | `bool` | `null` | no |
| <a name="input_express_route_circuit_name"></a> [express\_route\_circuit\_name](#input\_express\_route\_circuit\_name) | (Required) The name of the Express Route Circuit that this Express Route Connection connects with. | `string` | n/a | yes |
| <a name="input_express_route_circuit_resource_group_name"></a> [express\_route\_circuit\_resource\_group\_name](#input\_express\_route\_circuit\_resource\_group\_name) | (Required) The name of the Resource Group where the Express Route circuit is located. | `string` | n/a | yes |
| <a name="input_express_route_connection_name"></a> [express\_route\_connection\_name](#input\_express\_route\_connection\_name) | (Required) The name which should be used for this Express Route Connection. | `string` | n/a | yes |
| <a name="input_express_route_gateway_bypass_enabled"></a> [express\_route\_gateway\_bypass\_enabled](#input\_express\_route\_gateway\_bypass\_enabled) | (Optional) Specified whether Fast Path is enabled for Virtual Wan Firewall Hub. | `bool` | `false` | no |
| <a name="input_express_route_gateway_name"></a> [express\_route\_gateway\_name](#input\_express\_route\_gateway\_name) | (Required) The name of the Express Route Gateway that this Express Route Connection connects with. | `string` | n/a | yes |
| <a name="input_express_route_gateway_resource_group_name"></a> [express\_route\_gateway\_resource\_group\_name](#input\_express\_route\_gateway\_resource\_group\_name) | (Required) The name of the Resource Group where the Express Route Gateway is located. | `string` | n/a | yes |
| <a name="input_private_link_fast_path_enabled"></a> [private\_link\_fast\_path\_enabled](#input\_private\_link\_fast\_path\_enabled) | (Optional) Bypass the Express Route gateway when accessing private-links. When enabled express\_route\_gateway\_bypass\_enabled must be set to true. | `bool` | `false` | no |
| <a name="input_routing"></a> [routing](#input\_routing) | (Optional) A routing block as defined below. | <pre>object({<br>    associated_route_table_id = optional(string)<br>    inbound_route_map_id      = optional(string)<br>    outbound_route_map_id     = optional(string)<br>    propagated_route_table = optional(object({<br>      labels          = optional(list(string))<br>      route_table_ids = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_routing_weight"></a> [routing\_weight](#input\_routing\_weight) | (Optional) The routing weight associated to the Express Route Connection. | `number` | `0` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_express_route_connection_id"></a> [express\_route\_connection\_id](#output\_express\_route\_connection\_id) | The ID of the ExpressRoute Connection. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
