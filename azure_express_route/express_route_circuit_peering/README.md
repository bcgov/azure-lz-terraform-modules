# express_route_circuit_peering

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
| [azurerm_express_route_circuit_peering.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_circuit_peering"></a> [circuit\_peering](#input\_circuit\_peering) | Express Route circuit peering configuration | <pre>list(object({<br>    peering_type                  = string<br>    express_route_circuit_name    = string<br>    vlan_id                       = number<br>    primary_peer_address_prefix   = optional(string)<br>    secondary_peer_address_prefix = optional(string)<br>    ipv4_enabled                  = optional(bool, true)<br>    shared_key                    = optional(string, null)<br>    peer_asn                      = optional(number, null)<br>    microsoft_peering_config = optional(object({<br>      advertised_public_prefixes = list(string)<br>      customer_asn               = optional(number, 0)<br>      routing_registry_name      = optional(string, "NONE")<br>      advertised_communities     = optional(list(string))<br>    }), null)<br>    ipv6 = optional(object({<br>      primary_peer_address_prefix   = string<br>      secondary_peer_address_prefix = string<br>      enabled                       = optional(bool, true)<br>      microsoft_peering = optional(object({<br>        advertised_public_prefixes = list(string)<br>        customer_asn               = optional(number, 0)<br>        routing_registry_name      = optional(string, "NONE")<br>        advertised_communities     = optional(list(string))<br>      }), null)<br>      route_filter_id = optional(string, null)<br>    }), null)<br>    route_filter_id = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the ExpressRoute circuit. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_express_route_circuit_peering_id"></a> [express\_route\_circuit\_peering\_id](#output\_express\_route\_circuit\_peering\_id) | The ID of the ExpressRoute Circuit Peering. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
