# generic-firewall-snat

Isolated expansion VNet using an existing firewall as a private SNAT boundary. Use this when the workload must reach enterprise destinations beyond the directly peered routable VNet without advertising the isolated prefix.

The module does not modify shared firewall policy. Apply `required_firewall_routes`, `required_firewall_rules`, and `required_private_snat` from a platform networking deployment.

Copy `terraform.tfvars.example` to `terraform.tfvars` and replace placeholders before planning.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
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
| <a name="input_firewall_id"></a> [firewall\_id](#input\_firewall\_id) | Resource ID of the existing enterprise-routable firewall. | `string` | n/a | yes |
| <a name="input_firewall_private_ip"></a> [firewall\_private\_ip](#input\_firewall\_private\_ip) | Private IP of the existing firewall used as the SNAT boundary. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the expansion VNet. | `string` | `"canadacentral"` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Existing central private DNS zone IDs to link to the expansion VNet. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing network resource group name. | `string` | n/a | yes |
| <a name="input_routable_vnet_address_space"></a> [routable\_vnet\_address\_space](#input\_routable\_vnet\_address\_space) | Address space of the enterprise-routed workload VNet. | `list(string)` | n/a | yes |
| <a name="input_routable_vnet_id"></a> [routable\_vnet\_id](#input\_routable\_vnet\_id) | Resource ID of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_name"></a> [routable\_vnet\_name](#input\_routable\_vnet\_name) | Name of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_routable_vnet_resource_group_name"></a> [routable\_vnet\_resource\_group\_name](#input\_routable\_vnet\_resource\_group\_name) | Resource group of the enterprise-routed workload VNet. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription that contains the workload resource group. Use a placeholder in committed tfvars. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_required_firewall_routes"></a> [required\_firewall\_routes](#output\_required\_firewall\_routes) | n/a |
| <a name="output_required_firewall_rules"></a> [required\_firewall\_rules](#output\_required\_firewall\_rules) | n/a |
| <a name="output_required_private_snat"></a> [required\_private\_snat](#output\_required\_private\_snat) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
<!-- END_TF_DOCS -->
