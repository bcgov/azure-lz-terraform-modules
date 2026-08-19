# databricks

Classic Databricks compute-plane on an isolated expansion VNet with `egress.mode = "none"`.

```text
Routable Workload VNet          Isolated Databricks VNet
----------------------          ------------------------
Storage / KV / SQL PEs   <----> host + container subnets
                                dedicated PE subnet
                                  databricks_ui_api PE
```

Customer Azure resource Private Endpoints stay in the routable VNet and are reached over direct peering. The Databricks control-plane `databricks_ui_api` Private Endpoint must live in the workspace VNet.

This example does not create the workspace or those Private Endpoints. It also does not claim that Databricks-owned artifact storage, log storage, platform Event Hubs, or metastore endpoints are privatized. If those residual dependencies still need a path, use `firewall_snat` instead of `none`. Azure-provided DNS is the default. `spoke_dns_resolver` is optional (`enabled = false` unless you need private names).

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
| <a name="module_databricks_expansion"></a> [databricks\_expansion](#module\_databricks\_expansion) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"canadacentral"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_routable_vnet_address_space"></a> [routable\_vnet\_address\_space](#input\_routable\_vnet\_address\_space) | n/a | `list(string)` | n/a | yes |
| <a name="input_routable_vnet_id"></a> [routable\_vnet\_id](#input\_routable\_vnet\_id) | n/a | `string` | n/a | yes |
| <a name="input_routable_vnet_name"></a> [routable\_vnet\_name](#input\_routable\_vnet\_name) | n/a | `string` | n/a | yes |
| <a name="input_routable_vnet_resource_group_name"></a> [routable\_vnet\_resource\_group\_name](#input\_routable\_vnet\_resource\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_spoke_dns_resolver"></a> [spoke\_dns\_resolver](#input\_spoke\_dns\_resolver) | Optional spoke DNS Private Resolver. Off by default. | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    inbound_address_prefix     = optional(string)<br/>    outbound_address_prefix    = optional(string)<br/>    forward_to                 = optional(list(string), [])<br/>    additional_forward_domains = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
