# core

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alz"></a> [alz](#module\_alz) | Azure/caf-enterprise-scale/azurerm | 6.2.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.116.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_VNet-DNS-Settings"></a> [VNet-DNS-Settings](#input\_VNet-DNS-Settings) | Sets the VNet DNS settings for the policy assignment. | `list(any)` | n/a | yes |
| <a name="input_configure_connectivity_resources"></a> [configure\_connectivity\_resources](#input\_configure\_connectivity\_resources) | Configuration settings for "connectivity" resources. | `any` | n/a | yes |
| <a name="input_configure_management_resources"></a> [configure\_management\_resources](#input\_configure\_management\_resources) | Configuration settings for "management" resources. | `any` | n/a | yes |
| <a name="input_policy_effect"></a> [policy\_effect](#input\_policy\_effect) | Sets the effect for the policy assignment. | `string` | `null` | no |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | Sets the location for "primary" resources to be created in. | `string` | n/a | yes |
| <a name="input_root_id"></a> [root\_id](#input\_root\_id) | Sets the value used for generating unique resource naming within the module. | `string` | n/a | yes |
| <a name="input_root_name"></a> [root\_name](#input\_root\_name) | Sets the value used for the "intermediate root" management group display name. | `string` | n/a | yes |
| <a name="input_root_parent_id"></a> [root\_parent\_id](#input\_root\_parent\_id) | Sets the value for the parent management group. | `string` | n/a | yes |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | Sets the location for "secondary" resources to be created in. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity) | Subscription ID to use for "identity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
