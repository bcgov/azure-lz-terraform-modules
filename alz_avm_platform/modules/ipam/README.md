<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9, < 2.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm.management"></a> [azurerm.management](#provider\_azurerm.management) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_manager.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager) | resource |
| [azurerm_network_manager_ipam_pool.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_ipam_pool) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | (Optional) A description of the Network Manager. | `string` | `null` | no |
| <a name="input_ipam_pool_address_prefixes"></a> [ipam\_pool\_address\_prefixes](#input\_ipam\_pool\_address\_prefixes) | (Required) Specifies a list of IPv4 or IPv6 IP address prefixes. Changing this forces a new Network Manager IPAM Pool to be created. | `list(string)` | n/a | yes |
| <a name="input_ipam_pool_description"></a> [ipam\_pool\_description](#input\_ipam\_pool\_description) | (Optional) The description of the Network Manager IPAM Pool. | `string` | `null` | no |
| <a name="input_ipam_pool_display_name"></a> [ipam\_pool\_display\_name](#input\_ipam\_pool\_display\_name) | (Optional) The display name for the Network Manager IPAM Pool. | `string` | `null` | no |
| <a name="input_ipam_pool_name"></a> [ipam\_pool\_name](#input\_ipam\_pool\_name) | (Required) The name which should be used for this Network Manager IPAM Pool. Changing this forces a new Network Manager IPAM Pool to be created. | `string` | n/a | yes |
| <a name="input_ipam_pool_resource_group_name"></a> [ipam\_pool\_resource\_group\_name](#input\_ipam\_pool\_resource\_group\_name) | (Required) The name of the resource group in which the Network Manager IPAM Pool should exist. Changing this forces a new Network Manager IPAM Pool to be created. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure Region where the Network Manager IPAM Pool should exist. Changing this forces a new Network Manager IPAM Pool to be created. | `string` | n/a | yes |
| <a name="input_network_manager_name"></a> [network\_manager\_name](#input\_network\_manager\_name) | (Required) Specifies the name which should be used for this Network Manager. Changing this forces a new Network Manager to be created. | `string` | n/a | yes |
| <a name="input_parent_pool_name"></a> [parent\_pool\_name](#input\_parent\_pool\_name) | (Optional) The name of the parent IPAM Pool. Changing this forces a new Network Manager IPAM Pool to be created. | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required) Specifies the scope of the Network Manager. Changing this forces a new Network Manager to be created. At least one of the nested `management_group_ids` or `subscription_ids` attributes must be set. | <pre>object({<br/>    management_group_ids = optional(list(string), null)<br/>    subscription_ids     = optional(list(string), null)<br/>  })</pre> | n/a | yes |
| <a name="input_scope_accesses"></a> [scope\_accesses](#input\_scope\_accesses) | (Optional) A list of configuration deployment types. Possible values are Connectivity, SecurityAdmin and Routing, which specify whether Connectivity Configuration, Security Admin Configuration or Routing Configuration are allowed for the Network Manager. | `list(string)` | `null` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags which should be assigned to the Network Manager IPAM Pool. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_manager_ipam_pool_address_prefixes"></a> [network\_manager\_ipam\_pool\_address\_prefixes](#output\_network\_manager\_ipam\_pool\_address\_prefixes) | The address prefixes of the Network Manager IPAM Pool. |
| <a name="output_network_manager_ipam_pool_id"></a> [network\_manager\_ipam\_pool\_id](#output\_network\_manager\_ipam\_pool\_id) | The ID of the Network Manager IPAM Pool. |
| <a name="output_network_manager_ipam_pool_name"></a> [network\_manager\_ipam\_pool\_name](#output\_network\_manager\_ipam\_pool\_name) | The name of the Network Manager IPAM Pool. |
<!-- END_TF_DOCS -->
