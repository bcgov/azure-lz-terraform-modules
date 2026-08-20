# private_dns_resolver

Creates the central Private DNS Resolver, inbound and outbound endpoints, and two forwarding rulesets on the **same** outbound (Azure allows two):

| Ruleset | Purpose | Who links to it |
| --- | --- | --- |
| `${name}-dns-forwarding-ruleset` | On-prem / conditional suffixes from `forwarding_rules` | Not isolated expansion VNets |
| `${name}-isolated-expansion` | One rule: `.` → this inbound | Only `*-isolated-expansion` VNets, via `isolated_expansion_vnet.dns_forwarding_ruleset_id` |

This module does **not** create ruleset VNet links. Expansion modules create those links. Do not link the isolated-expansion ruleset to this resolver VNet or to `*-vwan-spoke` VNets. Do not put `.` on the on-prem ruleset.

Privatelink zones stay linked to this resolver VNet only. Isolated expansion VNets keep Azure-provided DNS (`168.63.129.16`); Azure DNS plus the outbound perform the forward.

Set `isolated_expansion_forwarding_ruleset.enabled = false` to skip the second ruleset.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.76 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.76 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_private_dns_resolver.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_dns_forwarding_ruleset.isolated_expansion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_dns_forwarding_ruleset) | resource |
| [azurerm_private_dns_resolver_dns_forwarding_ruleset.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_dns_forwarding_ruleset) | resource |
| [azurerm_private_dns_resolver_forwarding_rule.isolated_expansion_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_forwarding_rule) | resource |
| [azurerm_private_dns_resolver_forwarding_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_forwarding_rule) | resource |
| [azurerm_private_dns_resolver_inbound_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) | resource |
| [azurerm_private_dns_resolver_outbound_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_forwarding_rules"></a> [forwarding\_rules](#input\_forwarding\_rules) | (Optional) On-prem / conditional forwarding rules for the existing ruleset. Do not add a '.' catch-all here. Isolated expansion VNets use isolated\_expansion\_forwarding\_ruleset. | <pre>list(object({<br/>    name        = string<br/>    domain_name = string<br/>    enabled     = bool<br/>    target_dns_servers = list(object({<br/>      ip_address = string<br/>      port       = number<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_isolated_expansion_forwarding_ruleset"></a> [isolated\_expansion\_forwarding\_ruleset](#input\_isolated\_expansion\_forwarding\_ruleset) | Second forwarding ruleset on the existing outbound for *-isolated-expansion VNets. One rule: '.' → this resolver's inbound. This module does not create VNet links. Expansion modules pass the output ID as dns\_forwarding\_ruleset\_id. Do not link this ruleset to the resolver VNet or to *-vwan-spoke VNets. | <pre>object({<br/>    enabled = optional(bool, true)<br/>    name    = optional(string)<br/>  })</pre> | <pre>{<br/>  "enabled": true<br/>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_private_dns_resolver_name"></a> [private\_dns\_resolver\_name](#input\_private\_dns\_resolver\_name) | (Required) Specifies the name which should be used for this Private DNS Resolver. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Specifies the name of the Resource Group where the Private DNS Resolver should exist. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | (Required) Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_virtual_network_object"></a> [virtual\_network\_object](#input\_virtual\_network\_object) | (Required) The Virtual Network object that is linked to the Private DNS Resolver. | `any` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_isolated_expansion_dns_forwarding_ruleset"></a> [isolated\_expansion\_dns\_forwarding\_ruleset](#output\_isolated\_expansion\_dns\_forwarding\_ruleset) | The isolated-expansion forwarding ruleset resource, or null when disabled. |
| <a name="output_isolated_expansion_dns_forwarding_ruleset_id"></a> [isolated\_expansion\_dns\_forwarding\_ruleset\_id](#output\_isolated\_expansion\_dns\_forwarding\_ruleset\_id) | Resource ID of the isolated-expansion forwarding ruleset. Pass to isolated\_expansion\_vnet as dns\_forwarding\_ruleset\_id. Null when isolated\_expansion\_forwarding\_ruleset.enabled is false. Do not link this ruleset to the resolver VNet or to *-vwan-spoke VNets. |
| <a name="output_private_dns_resolver"></a> [private\_dns\_resolver](#output\_private\_dns\_resolver) | The ID of the Private DNS Resolver. |
| <a name="output_private_dns_resolver_dns_forwarding_ruleset"></a> [private\_dns\_resolver\_dns\_forwarding\_ruleset](#output\_private\_dns\_resolver\_dns\_forwarding\_ruleset) | The ID of the Private DNS Resolver DNS Forwarding Ruleset. |
| <a name="output_private_dns_resolver_forwarding_rules"></a> [private\_dns\_resolver\_forwarding\_rules](#output\_private\_dns\_resolver\_forwarding\_rules) | Map of Private DNS Resolver Forwarding Rules. |
| <a name="output_private_dns_resolver_inbound_endpoint"></a> [private\_dns\_resolver\_inbound\_endpoint](#output\_private\_dns\_resolver\_inbound\_endpoint) | The ID of the Private DNS Resolver Inbound Endpoint. |
| <a name="output_private_dns_resolver_outbound_endpoint"></a> [private\_dns\_resolver\_outbound\_endpoint](#output\_private\_dns\_resolver\_outbound\_endpoint) | The ID of the Private DNS Resolver Outbound Endpoint. |
<!-- END_TF_DOCS -->
