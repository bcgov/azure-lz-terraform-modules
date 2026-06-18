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
| <a name="provider_azurerm.connectivity"></a> [azurerm.connectivity](#provider\_azurerm.connectivity) | ~> 4.0 |
| <a name="provider_azurerm.management"></a> [azurerm.management](#provider\_azurerm.management) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network_flow_logs"></a> [network\_flow\_logs](#module\_network\_flow\_logs) | Azure/avm-res-network-networkwatcher/azurerm | 0.3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_manager_ipam_pool_static_cidr.reservations](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_ipam_pool_static_cidr) | resource |
| [azurerm_network_security_group.github_hosted_runners_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.ghrunners](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_hub_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection) | resource |
| [azurerm_virtual_network.ghrunners_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_virtual_hub.vwan_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_hub) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) Which Azure environment to deploy to. Options are: LIVE or FORGE. | `string` | n/a | yes |
| <a name="input_github_hosted_runners_subnet_address_prefix"></a> [github\_hosted\_runners\_subnet\_address\_prefix](#input\_github\_hosted\_runners\_subnet\_address\_prefix) | (Required) The address prefix for the GitHub hosted runners subnet (ie. 28). No slash needed. | `number` | n/a | yes |
| <a name="input_github_hosted_runners_subnet_name"></a> [github\_hosted\_runners\_subnet\_name](#input\_github\_hosted\_runners\_subnet\_name) | (Required) The name of the subnet to use for the GitHub hosted runners (which will be VNet injected) | `string` | `"github-runners"` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_manager_ipam_pool_id"></a> [network\_manager\_ipam\_pool\_id](#input\_network\_manager\_ipam\_pool\_id) | Azure IPAM Pool ID | `string` | n/a | yes |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | The primary location for resources | `string` | `"canadacentral"` | no |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | The secondary location for resources | `string` | `"canadaeast"` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | (Required) The address space for the virtual network (ie. 24). No slash needed. | `number` | `24` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | (Required) The name of the virtual network to create | `string` | n/a | yes |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | (Required) The name of the resource group to create the virtual network in | `string` | n/a | yes |
| <a name="input_virtual_wan_hub_name"></a> [virtual\_wan\_hub\_name](#input\_virtual\_wan\_hub\_name) | (Required) Name of the Virtual WAN Hub to connect to. | `string` | n/a | yes |
| <a name="input_virtual_wan_hub_resource_group"></a> [virtual\_wan\_hub\_resource\_group](#input\_virtual\_wan\_hub\_resource\_group) | (Required) Resource Group of the Virtual WAN hub. | `string` | n/a | yes |
| <a name="input_vnet_flow_logs_storage_account_id"></a> [vnet\_flow\_logs\_storage\_account\_id](#input\_vnet\_flow\_logs\_storage\_account\_id) | Storage account ID for storing VNet flow logs | `string` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | Log Analytics workspace ID for traffic analytics | `string` | n/a | yes |
| <a name="input_workspace_resource_id"></a> [workspace\_resource\_id](#input\_workspace\_resource\_id) | Log Analytics workspace resource ID for traffic analytics | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip_reservation"></a> [ip\_reservation](#output\_ip\_reservation) | The IPAM Pool Static CIDR Reservation for GitHub Runners VNet. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The Resource Group ID where the GitHub Runners VNet is deployed. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The subnet ID for GitHub Runners delegated subnet. This is used by the GitHub Network Settings object for Service Association Links. |
| <a name="output_virtual_network"></a> [virtual\_network](#output\_virtual\_network) | The Virtual Network object for GitHub Runners VNet. |
<!-- END_TF_DOCS -->
