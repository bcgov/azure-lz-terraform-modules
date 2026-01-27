# virtual_network

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_manager_ipam_pool_static_cidr.reservations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_ipam_pool_static_cidr) | resource |
| [azurerm_network_security_group.github_hosted_runners_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.ghrunners](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_network.ghrunners_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | (Optional) Which Azure environment to deploy to. Options are: forge, or live. | `string` | n/a | yes |
| <a name="input_github_hosted_runners_subnet_address_prefix"></a> [github\_hosted\_runners\_subnet\_address\_prefix](#input\_github\_hosted\_runners\_subnet\_address\_prefix) | (Required) The address prefix for the GitHub hosted runners subnet (ie. 28). No slash needed. | `number` | n/a | yes |
| <a name="input_github_hosted_runners_subnet_name"></a> [github\_hosted\_runners\_subnet\_name](#input\_github\_hosted\_runners\_subnet\_name) | (Required) The name of the subnet to use for the GitHub hosted runners (which will be VNet injected) | `string` | `"github-runners"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_manager_ipam_pool_id"></a> [network\_manager\_ipam\_pool\_id](#input\_network\_manager\_ipam\_pool\_id) | Azure IPAM Pool ID | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | (Required) The address space for the virtual network (ie. 24). No slash needed. | `number` | `24` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) The name of the virtual network to create | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | (Required) The name of the resource group to create the virtual network in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The Resource Group ID where the GitHub Runners VNet is deployed. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The subnet ID for GitHub Runners delegated subnet. This is used by the GitHub Network Settings object for Service Association Links. |
<!-- END_TF_DOCS -->
