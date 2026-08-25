# greenfield-vwan

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12, < 2.0 |
| <a name="requirement_alz"></a> [alz](#requirement\_alz) | ~> 0.21 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.35 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_platform"></a> [platform](#module\_platform) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_alz_library_references"></a> [custom\_alz\_library\_references](#input\_custom\_alz\_library\_references) | n/a | `list(any)` | `[]` | no |
| <a name="input_enable_amba"></a> [enable\_amba](#input\_enable\_amba) | n/a | `bool` | `false` | no |
| <a name="input_enable_centralized_logging"></a> [enable\_centralized\_logging](#input\_enable\_centralized\_logging) | n/a | `bool` | `true` | no |
| <a name="input_enable_express_route"></a> [enable\_express\_route](#input\_enable\_express\_route) | n/a | `bool` | `false` | no |
| <a name="input_enable_s2s_vpn"></a> [enable\_s2s\_vpn](#input\_enable\_s2s\_vpn) | n/a | `bool` | `false` | no |
| <a name="input_express_route_circuit_connections_by_hub"></a> [express\_route\_circuit\_connections\_by\_hub](#input\_express\_route\_circuit\_connections\_by\_hub) | n/a | `map(any)` | `{}` | no |
| <a name="input_external_base_firewall_policy_id"></a> [external\_base\_firewall\_policy\_id](#input\_external\_base\_firewall\_policy\_id) | n/a | `string` | `null` | no |
| <a name="input_management_automation_account_name"></a> [management\_automation\_account\_name](#input\_management\_automation\_account\_name) | n/a | `string` | `"aa-alz-management"` | no |
| <a name="input_management_group_names"></a> [management\_group\_names](#input\_management\_group\_names) | n/a | <pre>object({<br/>    root         = optional(string, "alz")<br/>    platform     = optional(string, "platform")<br/>    management   = optional(string, "management")<br/>    connectivity = optional(string, "connectivity")<br/>    identity     = optional(string, "identity")<br/>    security     = optional(string, "security")<br/>    landingzones = optional(string, "landingzones")<br/>  })</pre> | `{}` | no |
| <a name="input_management_log_analytics_workspace_name"></a> [management\_log\_analytics\_workspace\_name](#input\_management\_log\_analytics\_workspace\_name) | n/a | `string` | `"law-alz-management"` | no |
| <a name="input_management_resource_group_name"></a> [management\_resource\_group\_name](#input\_management\_resource\_group\_name) | n/a | `string` | `"rg-alz-management"` | no |
| <a name="input_policy_default_values"></a> [policy\_default\_values](#input\_policy\_default\_values) | n/a | `map(string)` | `{}` | no |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | n/a | `string` | `"canadacentral"` | no |
| <a name="input_private_dns_enable_internet_fallback"></a> [private\_dns\_enable\_internet\_fallback](#input\_private\_dns\_enable\_internet\_fallback) | n/a | `bool` | `true` | no |
| <a name="input_private_dns_resolver_by_hub"></a> [private\_dns\_resolver\_by\_hub](#input\_private\_dns\_resolver\_by\_hub) | n/a | `map(any)` | `{}` | no |
| <a name="input_private_dns_resolver_virtual_network_resource_id_by_hub"></a> [private\_dns\_resolver\_virtual\_network\_resource\_id\_by\_hub](#input\_private\_dns\_resolver\_virtual\_network\_resource\_id\_by\_hub) | n/a | `map(string)` | `{}` | no |
| <a name="input_private_dns_zones_by_hub"></a> [private\_dns\_zones\_by\_hub](#input\_private\_dns\_zones\_by\_hub) | n/a | `map(any)` | `{}` | no |
| <a name="input_routing_intents_by_hub"></a> [routing\_intents\_by\_hub](#input\_routing\_intents\_by\_hub) | n/a | `map(any)` | `{}` | no |
| <a name="input_subscription_ids"></a> [subscription\_ids](#input\_subscription\_ids) | n/a | <pre>object({<br/>    management   = string<br/>    connectivity = string<br/>    identity     = string<br/>    security     = string<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | <pre>{<br/>  "deployedBy": "alz_avm_platform_example"<br/>}</pre> | no |
| <a name="input_virtual_hubs"></a> [virtual\_hubs](#input\_virtual\_hubs) | n/a | `any` | <pre>{<br/>  "canadacentral": {<br/>    "firewall": {<br/>      "enabled": true<br/>    },<br/>    "hub": {<br/>      "address_prefix": "10.40.0.0/23"<br/>    },<br/>    "location": "canadacentral",<br/>    "private_dns_zones": {<br/>      "enabled": true<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_virtual_wan_settings"></a> [virtual\_wan\_settings](#input\_virtual\_wan\_settings) | n/a | `any` | <pre>{<br/>  "virtual_wan": {<br/>    "name": "vwan-hub-canadacentral-001"<br/>  }<br/>}</pre> | no |
| <a name="input_vpn_site_connections_by_hub"></a> [vpn\_site\_connections\_by\_hub](#input\_vpn\_site\_connections\_by\_hub) | n/a | `map(any)` | `{}` | no |
| <a name="input_vpn_sites_by_hub"></a> [vpn\_sites\_by\_hub](#input\_vpn\_sites\_by\_hub) | n/a | `map(any)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
