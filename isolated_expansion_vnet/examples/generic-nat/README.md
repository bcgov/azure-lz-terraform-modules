# generic-nat

Isolated expansion VNet using NAT Gateway egress. Use this when the workload only needs the directly peered routable VNet, private endpoints in that VNet, and public outbound connectivity.

Azure-provided DNS is the default. Pass `dns_forwarding_ruleset_id` or set `spoke_dns_resolver.enabled = true` when you need private names.

Copy `terraform.tfvars.example` to `terraform.tfvars` and replace placeholders before planning.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_compute_expansion"></a> [compute\_expansion](#module\_compute\_expansion) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dns_forwarding_ruleset_id"></a> [dns\_forwarding\_ruleset\_id](#input\_dns\_forwarding\_ruleset\_id) | Optional central isolated-expansion forwarding ruleset ID. The expansion VNet keeps Azure-provided DNS. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the expansion VNet. | `string` | `"canadacentral"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing network resource group name. | `string` | n/a | yes |
| <a name="input_routable_vnet_address_space"></a> [routable\_vnet\_address\_space](#input\_routable\_vnet\_address\_space) | Address space of the enterprise-routed workload VNet. | `list(string)` | n/a | yes |
| <a name="input_routable_vnet_id"></a> [routable\_vnet\_id](#input\_routable\_vnet\_id) | Resource ID of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_name"></a> [routable\_vnet\_name](#input\_routable\_vnet\_name) | Name of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_resource_group_name"></a> [routable\_vnet\_resource\_group\_name](#input\_routable\_vnet\_resource\_group\_name) | Resource group of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_spoke_dns_resolver"></a> [spoke\_dns\_resolver](#input\_spoke\_dns\_resolver) | Optional spoke DNS Private Resolver. Off by default. Mutually exclusive with dns\_forwarding\_ruleset\_id. | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    inbound_address_prefix     = optional(string)<br/>    outbound_address_prefix    = optional(string)<br/>    forward_to                 = optional(list(string), [])<br/>    additional_forward_domains = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription that contains the workload resource group. Use a placeholder in committed tfvars. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | n/a |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
<!-- END_TF_DOCS -->
