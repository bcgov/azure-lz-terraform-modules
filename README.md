# terraform-azure-lz-project-set

This Terraform module is designed to provision and manage a set of Azure landing zones (subscriptions) tailored for different environments such as development, testing, production, and tools.

For each environment, the module will create a subscription, a network resource group, and a virtual network. Each virtual network is connected to a central virtual WAN hub, enhancing connectivity across the Azure landing zone.

## Terraform module documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.109.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.109.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lz_vending"></a> [lz\_vending](#module\_lz\_vending) | Azure/lz-vending/azurerm | 4.1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group.project_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.landing_zones](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to apply to all resources | `map(string)` | <pre>{<br>  "deployedBy": "Terraform"<br>}</pre> | no |
| <a name="input_license_plate"></a> [license\_plate](#input\_license\_plate) | The license plate identifier for the project | `string` | n/a | yes |
| <a name="input_lz_management_group_id"></a> [lz\_management\_group\_id](#input\_lz\_management\_group\_id) | The ID of the management group for landing zones | `string` | n/a | yes |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | The primary location for resources | `string` | `"canadacentral"` | no |
| <a name="input_project_set_name"></a> [project\_set\_name](#input\_project\_set\_name) | The name of the project set | `string` | n/a | yes |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | The secondary location for resources | `string` | `"canadaeast"` | no |
| <a name="input_subscription_billing_scope"></a> [subscription\_billing\_scope](#input\_subscription\_billing\_scope) | The billing scope for the subscription | `string` | n/a | yes |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | Configuration details for each subscription | <pre>map(object({<br>    name : string<br>    display_name : string<br>    budget_amount : optional(number, 0)<br>    network : object({<br>      enabled : bool<br>      address_space : list(string)<br>      dns_servers : optional(list(string))<br>    })<br>  }))</pre> | n/a | yes |
| <a name="input_vwan_hub_resource_id"></a> [vwan\_hub\_resource\_id](#input\_vwan\_hub\_resource\_id) | The resource ID for the virtual WAN hub | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_id"></a> [management\_group\_id](#output\_management\_group\_id) | The management group ID for the project set. |
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | The subscription IDs of each landing zone created. |
<!-- END_TF_DOCS -->
