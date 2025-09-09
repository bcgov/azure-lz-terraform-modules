# azure_ip_group

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_assert"></a> [assert](#requirement\_assert) | ~> 0.16.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.112.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.112.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_ip_group.ipgroup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/ip_group) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_group"></a> [ip\_group](#input\_ip\_group) | Configuration for creating IP Groups | <pre>list(object({<br/>    name         = string<br/>    ip_addresses = set(string)<br/>    tags         = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the resource should be deployed. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The resource group where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip_group_ids"></a> [ip\_group\_ids](#output\_ip\_group\_ids) | Map of IP Group names to their IDs |
| <a name="output_ip_groups"></a> [ip\_groups](#output\_ip\_groups) | Map of created IP Groups |
<!-- END_TF_DOCS -->
