<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.group_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_role_assignment.group_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_users.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_restricted_role_ids"></a> [additional\_restricted\_role\_ids](#input\_additional\_restricted\_role\_ids) | List of additional role IDs that should be restricted using conditional access policies on the owners group | `list(string)` | `[]` | no |
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Email of the admin user who will be an owner of all groups | `string` | n/a | yes |
| <a name="input_contributors"></a> [contributors](#input\_contributors) | List of email addresses for users who should be in the Contributors group | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., Forge, Prod) | `string` | n/a | yes |
| <a name="input_license_plate"></a> [license\_plate](#input\_license\_plate) | License plate identifier for the project | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | List of email addresses for users who should be in the Owners group | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_readers"></a> [readers](#input\_readers) | List of email addresses for users who should be in the Readers group | `list(string)` | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope at which the role assignments should be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_groups"></a> [groups](#output\_groups) | Map of created Azure AD groups |
<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.group_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_role_assignment.group_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_user.users](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Email of the admin user who will be an owner of all groups | `string` | n/a | yes |
| <a name="input_contributors"></a> [contributors](#input\_contributors) | List of email addresses for users who should be in the Contributors group | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., Forge, Prod) | `string` | n/a | yes |
| <a name="input_license_plate"></a> [license\_plate](#input\_license\_plate) | License plate identifier for the project | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | List of email addresses for users who should be in the Owners group | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | n/a | yes |
| <a name="input_readers"></a> [readers](#input\_readers) | List of email addresses for users who should be in the Readers group | `list(string)` | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope at which the role assignments should be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_groups"></a> [groups](#output\_groups) | Map of created Azure AD groups |
<!-- END_TF_DOCS -->
