# express_route_circuit

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
| [azurerm_express_route_circuit.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_express_route_circuit"></a> [express\_route\_circuit](#input\_express\_route\_circuit) | Express Route circuit configuration | <pre>list(object({<br/>    express_route_circuit_name = string<br/>    location                   = string<br/>    sku = object({<br/>      tier   = string<br/>      family = string<br/>    })<br/>    service_provider_name    = optional(string, null)<br/>    peering_location         = optional(string, null)<br/>    bandwidth_in_mbps        = optional(number, null)<br/>    allow_classic_operations = optional(bool, false)<br/>    express_route_port_id    = optional(string, null)<br/>    bandwidth_in_gbps        = optional(number, null)<br/>    authorization_key        = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | (Required) Specifies the supported Azure location where the resource exists. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the ExpressRoute circuit. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_express_route_circuit_id"></a> [express\_route\_circuit\_id](#output\_express\_route\_circuit\_id) | The ID of the ExpressRoute Circuit. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the Resource Group. |
| <a name="output_service_key"></a> [service\_key](#output\_service\_key) | The service key of the ExpressRoute Circuit. |
| <a name="output_service_provider_provisioning_state"></a> [service\_provider\_provisioning\_state](#output\_service\_provider\_provisioning\_state) | The provisioning state of the ExpressRoute Circuit Service Provider. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
