# firewall_policy_rcg

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
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
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure Region where the User Assigned Identity should exist. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group where the User Assigned Identity should exist. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | (Required) Specifies the name of this User Assigned Identity. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_id"></a> [client\_id](#output\_client\_id) | The Client ID of the Service Principal associated with this User Assigned Identity. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The Principal ID of the Service Principal associated with this User Assigned Identity. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The Tenant ID of the Service Principal associated with this User Assigned Identity. |
| <a name="output_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#output\_user\_assigned\_identity\_id) | The ID of the User Assigned Identity. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
