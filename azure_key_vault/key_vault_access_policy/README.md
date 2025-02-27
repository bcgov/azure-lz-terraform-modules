# firewall_policy_rcg

<!-- BEGIN_TF_DOCS -->
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
| [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | (Optional) The object ID of an Application in Azure Active Directory. | `string` | `null` | no |
| <a name="input_certificate_permissions"></a> [certificate\_permissions](#input\_certificate\_permissions) | (Optional) List of certificate permissions. | `list(string)` | `[]` | no |
| <a name="input_key_permissions"></a> [key\_permissions](#input\_key\_permissions) | (Optional) List of key permissions. | `list(string)` | `[]` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | (Required) Specifies the id of the Key Vault resource. | `string` | n/a | yes |
| <a name="input_object_id"></a> [object\_id](#input\_object\_id) | (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. | `string` | n/a | yes |
| <a name="input_secret_permissions"></a> [secret\_permissions](#input\_secret\_permissions) | (Optional) List of secret permissions. | `list(string)` | `[]` | no |
| <a name="input_storage_permissions"></a> [storage\_permissions](#input\_storage\_permissions) | (Optional) List of storage permissions. | `list(string)` | `[]` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | (Required) Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_policy_id"></a> [key\_vault\_policy\_id](#output\_key\_vault\_policy\_id) | The ID of the Key Vault Access Policy. |
<!-- END_TF_DOCS -->
