<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.112.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_express_route_circuit.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit) | resource |
| [azurerm_express_route_circuit_peering.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_express_route_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_connection) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_key"></a> [authorization\_key](#input\_authorization\_key) | (Optional) The authorization key to establish the Express Route Connection. | `string` | `null` | no |
| <a name="input_circuit_peering"></a> [circuit\_peering](#input\_circuit\_peering) | Express Route circuit peering configuration | <pre>list(object({<br>    peering_type                  = string<br>    express_route_circuit_name    = string<br>    vlan_id                       = number<br>    primary_peer_address_prefix   = optional(string)<br>    secondary_peer_address_prefix = optional(string)<br>    ipv4_enabled                  = optional(bool, true)<br>    shared_key                    = optional(string, null)<br>    peer_asn                      = optional(number, null)<br>    microsoft_peering_config = optional(object({<br>      advertised_public_prefixes = list(string)<br>      customer_asn               = optional(number, 0)<br>      routing_registry_name      = optional(string, "NONE")<br>      advertised_communities     = optional(list(string))<br>    }), null)<br>    ipv6 = optional(object({<br>      primary_peer_address_prefix   = string<br>      secondary_peer_address_prefix = string<br>      enabled                       = optional(bool, true)<br>      microsoft_peering = optional(object({<br>        advertised_public_prefixes = list(string)<br>        customer_asn               = optional(number, 0)<br>        routing_registry_name      = optional(string, "NONE")<br>        advertised_communities     = optional(list(string))<br>      }), null)<br>      route_filter_id = optional(string, null)<br>    }), null)<br>    route_filter_id = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_enable_internet_security"></a> [enable\_internet\_security](#input\_enable\_internet\_security) | (Optional) Is Internet security enabled for this Express Route Connection? | `bool` | `null` | no |
| <a name="input_express_route_circuit"></a> [express\_route\_circuit](#input\_express\_route\_circuit) | Express Route circuit configuration | <pre>list(object({<br>    express_route_circuit_name = string<br>    location                   = string<br>    sku = object({<br>      tier   = string<br>      family = string<br>    })<br>    service_provider_name    = optional(string, null)<br>    peering_location         = optional(string, null)<br>    bandwidth_in_mbps        = optional(number, null)<br>    allow_classic_operations = optional(bool, false)<br>    express_route_port_id    = optional(string, null)<br>    bandwidth_in_gbps        = optional(number, null)<br>    authorization_key        = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_express_route_connection_name"></a> [express\_route\_connection\_name](#input\_express\_route\_connection\_name) | (Required) The name which should be used for this Express Route Connection. | `string` | n/a | yes |
| <a name="input_express_route_gateway_bypass_enabled"></a> [express\_route\_gateway\_bypass\_enabled](#input\_express\_route\_gateway\_bypass\_enabled) | (Optional) Specified whether Fast Path is enabled for Virtual Wan Firewall Hub. | `bool` | `false` | no |
| <a name="input_express_route_gateway_name"></a> [express\_route\_gateway\_name](#input\_express\_route\_gateway\_name) | (Required) The name of the Express Route Gateway that this Express Route Connection connects with. | `string` | n/a | yes |
| <a name="input_express_route_gateway_resource_group_name"></a> [express\_route\_gateway\_resource\_group\_name](#input\_express\_route\_gateway\_resource\_group\_name) | (Required) The name of the Resource Group where the Express Route Gateway is located. | `string` | n/a | yes |
| <a name="input_private_link_fast_path_enabled"></a> [private\_link\_fast\_path\_enabled](#input\_private\_link\_fast\_path\_enabled) | (Optional) Bypass the Express Route gateway when accessing private-links. When enabled express\_route\_gateway\_bypass\_enabled must be set to true. | `bool` | `false` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | (Required) Specifies the supported Azure location where the resource exists. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the ExpressRoute circuit. | `string` | n/a | yes |
| <a name="input_routing"></a> [routing](#input\_routing) | (Optional) A routing block as defined below. | <pre>object({<br>    associated_route_table_id = optional(string)<br>    inbound_route_map_id      = optional(string)<br>    outbound_route_map_id     = optional(string)<br>    propagated_route_table = optional(object({<br>      labels          = optional(list(string))<br>      route_table_ids = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_routing_weight"></a> [routing\_weight](#input\_routing\_weight) | (Optional) The routing weight associated to the Express Route Connection. | `number` | `0` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_express_route_circuit_id"></a> [express\_route\_circuit\_id](#output\_express\_route\_circuit\_id) | The ID of the ExpressRoute Circuit. |
| <a name="output_express_route_circuit_peering_id"></a> [express\_route\_circuit\_peering\_id](#output\_express\_route\_circuit\_peering\_id) | The ID of the ExpressRoute Circuit Peering. |
| <a name="output_express_route_connection_id"></a> [express\_route\_connection\_id](#output\_express\_route\_connection\_id) | The ID of the ExpressRoute Connection. |
| <a name="output_service_key"></a> [service\_key](#output\_service\_key) | The service key of the ExpressRoute Circuit. |
| <a name="output_service_provider_provisioning_state"></a> [service\_provider\_provisioning\_state](#output\_service\_provider\_provisioning\_state) | The provisioning state of the ExpressRoute Circuit Service Provider. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.112.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.112.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_express_route_circuit.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit) | resource |
| [azurerm_express_route_circuit_peering.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_express_route_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_connection) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_key"></a> [authorization\_key](#input\_authorization\_key) | (Optional) The authorization key to establish the Express Route Connection. | `string` | `null` | no |
| <a name="input_circuit_peering"></a> [circuit\_peering](#input\_circuit\_peering) | Express Route circuit peering configuration | <pre>list(object({<br>    peering_type                  = string<br>    express_route_circuit_name    = string<br>    vlan_id                       = number<br>    primary_peer_address_prefix   = optional(string)<br>    secondary_peer_address_prefix = optional(string)<br>    ipv4_enabled                  = optional(bool, true)<br>    shared_key                    = optional(string, null)<br>    peer_asn                      = optional(number, null)<br>    microsoft_peering_config = optional(object({<br>      advertised_public_prefixes = list(string)<br>      customer_asn               = optional(number, 0)<br>      routing_registry_name      = optional(string, "NONE")<br>      advertised_communities     = optional(list(string))<br>    }), null)<br>    ipv6 = optional(object({<br>      primary_peer_address_prefix   = string<br>      secondary_peer_address_prefix = string<br>      enabled                       = optional(bool, true)<br>      microsoft_peering = optional(object({<br>        advertised_public_prefixes = list(string)<br>        customer_asn               = optional(number, 0)<br>        routing_registry_name      = optional(string, "NONE")<br>        advertised_communities     = optional(list(string))<br>      }), null)<br>      route_filter_id = optional(string, null)<br>    }), null)<br>    route_filter_id = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_enable_internet_security"></a> [enable\_internet\_security](#input\_enable\_internet\_security) | (Optional) Is Internet security enabled for this Express Route Connection? | `bool` | `null` | no |
| <a name="input_express_route_circuit"></a> [express\_route\_circuit](#input\_express\_route\_circuit) | Express Route circuit configuration | <pre>list(object({<br>    express_route_circuit_name = string<br>    location                   = string<br>    sku = object({<br>      tier   = string<br>      family = string<br>    })<br>    service_provider_name    = optional(string, null)<br>    peering_location         = optional(string, null)<br>    bandwidth_in_mbps        = optional(number, null)<br>    allow_classic_operations = optional(bool, false)<br>    express_route_port_id    = optional(string, null)<br>    bandwidth_in_gbps        = optional(number, null)<br>    authorization_key        = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_express_route_connection_name"></a> [express\_route\_connection\_name](#input\_express\_route\_connection\_name) | (Required) The name which should be used for this Express Route Connection. | `string` | n/a | yes |
| <a name="input_express_route_gateway_bypass_enabled"></a> [express\_route\_gateway\_bypass\_enabled](#input\_express\_route\_gateway\_bypass\_enabled) | (Optional) Specified whether Fast Path is enabled for Virtual Wan Firewall Hub. | `bool` | `false` | no |
| <a name="input_express_route_gateway_name"></a> [express\_route\_gateway\_name](#input\_express\_route\_gateway\_name) | (Required) The name of the Express Route Gateway that this Express Route Connection connects with. | `string` | n/a | yes |
| <a name="input_express_route_gateway_resource_group_name"></a> [express\_route\_gateway\_resource\_group\_name](#input\_express\_route\_gateway\_resource\_group\_name) | (Required) The name of the Resource Group where the Express Route Gateway is located. | `string` | n/a | yes |
| <a name="input_private_link_fast_path_enabled"></a> [private\_link\_fast\_path\_enabled](#input\_private\_link\_fast\_path\_enabled) | (Optional) Bypass the Express Route gateway when accessing private-links. When enabled express\_route\_gateway\_bypass\_enabled must be set to true. | `bool` | `false` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | (Required) Specifies the supported Azure location where the resource exists. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the ExpressRoute circuit. | `string` | n/a | yes |
| <a name="input_routing"></a> [routing](#input\_routing) | (Optional) A routing block as defined below. | <pre>object({<br>    associated_route_table_id = optional(string)<br>    inbound_route_map_id      = optional(string)<br>    outbound_route_map_id     = optional(string)<br>    propagated_route_table = optional(object({<br>      labels          = optional(list(string))<br>      route_table_ids = optional(list(string))<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_routing_weight"></a> [routing\_weight](#input\_routing\_weight) | (Optional) The routing weight associated to the Express Route Connection. | `number` | `0` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_express_route_circuit_id"></a> [express\_route\_circuit\_id](#output\_express\_route\_circuit\_id) | The ID of the ExpressRoute Circuit. |
| <a name="output_express_route_circuit_peering_id"></a> [express\_route\_circuit\_peering\_id](#output\_express\_route\_circuit\_peering\_id) | The ID of the ExpressRoute Circuit Peering. |
| <a name="output_express_route_connection_id"></a> [express\_route\_connection\_id](#output\_express\_route\_connection\_id) | The ID of the ExpressRoute Connection. |
| <a name="output_service_key"></a> [service\_key](#output\_service\_key) | The service key of the ExpressRoute Circuit. |
| <a name="output_service_provider_provisioning_state"></a> [service\_provider\_provisioning\_state](#output\_service\_provider\_provisioning\_state) | The provisioning state of the ExpressRoute Circuit Service Provider. |
<!-- END_TF_DOCS -->