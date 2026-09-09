# generic-private-nat

Isolated expansion VNet using a Linux NVA in the routable spoke as a private SNAT boundary. Use this when the workload must reach enterprise destinations beyond the directly peered routable VNet without advertising the isolated prefix, and you want this module to create the hop.

The NVA SNATs isolated sources to its spoke IP. Leave the NVA subnet without a custom table so vWAN routing intent programs the hub path. Pass `spoke_route_table_id` only when the spoke already uses a custom UDR. The expansion VNet uses `hub_firewall_dns_servers`. Packet walks are in [ROUTING-AND-DNS.md](../../ROUTING-AND-DNS.md).

Prefer Entra ID SSH (`ssh_admin_group_object_id`). Leave `ssh_public_key` unset so the module generates a throwaway key for VM create; do not use that key to sign in.

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
| <a name="input_enterprise_routes"></a> [enterprise\_routes](#input\_enterprise\_routes) | Optional extra prefixes to steer to the NVA. Leave empty to use the default 0.0.0.0/0 egress route. | `list(string)` | `[]` | no |
| <a name="input_hub_firewall_dns_servers"></a> [hub\_firewall\_dns\_servers](#input\_hub\_firewall\_dns\_servers) | Hub firewall DNS proxy IPs. The expansion VNet uses these as custom DNS after SNAT. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the expansion VNet. | `string` | `"canadacentral"` | no |
| <a name="input_private_nat_subnet_address_prefix"></a> [private\_nat\_subnet\_address\_prefix](#input\_private\_nat\_subnet\_address\_prefix) | Unused /28 or larger prefix already in the routable spoke for the private NAT NVA. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing network resource group name. | `string` | n/a | yes |
| <a name="input_routable_vnet_address_space"></a> [routable\_vnet\_address\_space](#input\_routable\_vnet\_address\_space) | Address space of the enterprise-routed workload VNet. | `list(string)` | n/a | yes |
| <a name="input_routable_vnet_id"></a> [routable\_vnet\_id](#input\_routable\_vnet\_id) | Resource ID of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_name"></a> [routable\_vnet\_name](#input\_routable\_vnet\_name) | Name of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_resource_group_name"></a> [routable\_vnet\_resource\_group\_name](#input\_routable\_vnet\_resource\_group\_name) | Resource group of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_spoke_route_table_id"></a> [spoke\_route\_table\_id](#input\_spoke\_route\_table\_id) | Optional existing spoke route table to associate with the NVA subnet when the spoke already uses a custom UDR. Leave null so vWAN routing intent programs the NVA subnet. | `string` | `null` | no |
| <a name="input_ssh_admin_group_object_id"></a> [ssh\_admin\_group\_object\_id](#input\_ssh\_admin\_group\_object\_id) | Existing Entra security group object ID granted Virtual Machine Administrator Login on the NVA. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Optional OpenSSH public key. Omit to let the module generate a throwaway key for VM create. | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription that contains the workload resource group. Use a placeholder in committed tfvars. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_private_nat_private_ip"></a> [private\_nat\_private\_ip](#output\_private\_nat\_private\_ip) | n/a |
| <a name="output_private_nat_vm_id"></a> [private\_nat\_vm\_id](#output\_private\_nat\_vm\_id) | n/a |
| <a name="output_required_private_snat"></a> [required\_private\_snat](#output\_required\_private\_snat) | n/a |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
<!-- END_TF_DOCS -->
