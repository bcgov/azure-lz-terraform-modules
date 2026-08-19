# generic-firewall-snat

Isolated expansion VNet using a spoke Azure Firewall as a private SNAT hop. Use this when the workload must reach enterprise destinations beyond the directly peered routable VNet without advertising the isolated prefix.

The module creates `AzureFirewallSubnet` and `AzureFirewallManagementSubnet` in the routable spoke, plus a forced-tunnel Basic firewall that SNATs isolated sources to the firewall private IP. After SNAT, packets follow vWAN routing intent to the hub. The expansion VNet uses `hub_firewall_dns_servers`. The isolated prefix is never advertised. Set `sku_tier` to `Standard` or `Premium` when you need more than Basic throughput.

Pass two unused `/26` or larger prefixes already in the spoke address space. Azure forbids NSGs on those subnets. Landing-zone policy may need an exemption to create Azure Firewall in an application subscription. Packet walks are in [ROUTING-AND-DNS.md](../../ROUTING-AND-DNS.md).

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
| <a name="input_firewall_management_subnet_address_prefix"></a> [firewall\_management\_subnet\_address\_prefix](#input\_firewall\_management\_subnet\_address\_prefix) | Unused /26 or larger prefix already in the routable spoke for AzureFirewallManagementSubnet. | `string` | n/a | yes |
| <a name="input_firewall_subnet_address_prefix"></a> [firewall\_subnet\_address\_prefix](#input\_firewall\_subnet\_address\_prefix) | Unused /26 or larger prefix already in the routable spoke for AzureFirewallSubnet. | `string` | n/a | yes |
| <a name="input_hub_firewall_dns_servers"></a> [hub\_firewall\_dns\_servers](#input\_hub\_firewall\_dns\_servers) | Hub firewall DNS proxy IPs. The expansion VNet uses these as custom DNS after SNAT. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the expansion VNet. | `string` | `"canadacentral"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing network resource group name. | `string` | n/a | yes |
| <a name="input_routable_vnet_address_space"></a> [routable\_vnet\_address\_space](#input\_routable\_vnet\_address\_space) | Address space of the enterprise-routed workload VNet. | `list(string)` | n/a | yes |
| <a name="input_routable_vnet_id"></a> [routable\_vnet\_id](#input\_routable\_vnet\_id) | Resource ID of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_name"></a> [routable\_vnet\_name](#input\_routable\_vnet\_name) | Name of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_resource_group_name"></a> [routable\_vnet\_resource\_group\_name](#input\_routable\_vnet\_resource\_group\_name) | Resource group of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_spoke_route_table_id"></a> [spoke\_route\_table\_id](#input\_spoke\_route\_table\_id) | Optional existing spoke route table to associate with AzureFirewallSubnet when the spoke already uses a custom UDR. Leave null so vWAN routing intent programs the data subnet. | `string` | `null` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription that contains the workload resource group. Use a placeholder in committed tfvars. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | n/a |
| <a name="output_firewall_private_ip"></a> [firewall\_private\_ip](#output\_firewall\_private\_ip) | n/a |
| <a name="output_required_private_snat"></a> [required\_private\_snat](#output\_required\_private\_snat) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
<!-- END_TF_DOCS -->
