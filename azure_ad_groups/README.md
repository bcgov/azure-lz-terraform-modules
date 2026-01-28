# azure_ad_groups

Creates Azure AD groups (Owners, Contributors, Readers) for a project set and assigns them roles at the given scope.

## Group owners

Groups are created with the **Terraform execution identity** as owner (required for creation). The **admin email** user is then added as an owner.

**Key behaviour:**

- Group owners can be managed freely outside of Terraform (e.g. in the Azure portal) – Terraform will not remove them.
- However, if the **admin email** user is removed as an owner outside of Terraform, they will be **re-added on the next `terraform apply`**.
- If the **admin email input changes**, the old admin is removed and the new admin is added.

This is implemented using two `terraform_data` resources:

1. **`admin_owner`** – Manages the admin email lifecycle. Triggers replacement only when `admin_email` changes, using the destroy provisioner to remove the old admin and create provisioner to add the new one.

2. **`ensure_admin_present`** – Drift correction. This resource only exists when the admin is missing from a group's owners (detected via an external data source). When created, it adds the admin. When the admin is present, this resource is not in the `for_each` and is destroyed as a no-op.

Both cases (admin email change and external drift) are handled in a **single apply**.

**Requirements:**

- Azure CLI (`az`) and `jq` must be installed and authenticated where Terraform runs.
- The `hashicorp/external` provider (~> 2.0) is required.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.7.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.58.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.group_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_role_assignment.group_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [terraform_data.admin_owner](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.ensure_admin_present](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_users.members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/users) | data source |
| [external_external.group_owners](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

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
