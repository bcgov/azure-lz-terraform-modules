# key_vault_certificate

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
| [azurerm_key_vault_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate"></a> [certificate](#input\_certificate) | (Optional) A certificate block as defined below, used to Import an existing certificate. | <pre>object({<br/>    contents = string<br/>    password = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_certificate_name"></a> [certificate\_name](#input\_certificate\_name) | (Required) Specifies the name of the Key Vault Certificate. | `string` | n/a | yes |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | (Required) The ID of the Key Vault where the Certificate should be created. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | (Required) Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_certificate_id"></a> [key\_vault\_certificate\_id](#output\_key\_vault\_certificate\_id) | The ID of the Key Vault Certificate. |
| <a name="output_key_vault_certificate_name"></a> [key\_vault\_certificate\_name](#output\_key\_vault\_certificate\_name) | The name of the Key Vault Certificate. |
| <a name="output_key_vault_certificate_thumbprint"></a> [key\_vault\_certificate\_thumbprint](#output\_key\_vault\_certificate\_thumbprint) | The thumbprint of the Key Vault Certificate. |
| <a name="output_key_vault_secret_id"></a> [key\_vault\_secret\_id](#output\_key\_vault\_secret\_id) | The ID of the Key Vault Secret. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
