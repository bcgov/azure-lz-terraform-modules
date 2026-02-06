# azure_ad_groups

Creates Azure AD groups (Owners, Contributors, Readers) for a project set and assigns them roles at the given scope.

## Group owners behaviour

Groups are created with the **Terraform execution identity** and **admin email** user as initial owners.

**Key behaviour:**

- **Portal-added owners are preserved** – After creation, Terraform uses `lifecycle { ignore_changes = [owners] }` so owners added in the Azure portal (e.g. Technical Leads, managed identities for CI/CD) are never removed.

- **Admin email changes are handled automatically** – When `admin_email` changes, a `null_resource` with triggers:
  1. Removes the **old** admin email user as owner (using the value stored in Terraform state)
  2. Adds the **new** admin email user as owner

This prevents accumulating old admins as group owners over time.

**Edge case:** If the old admin is the **only** owner of a group, Azure AD will not allow removal (minimum 1 owner required). In this case, the new admin is added but the old admin remains. You may need to manually remove the old admin after ensuring other owners exist.

**Requirements:**

- Azure CLI (`az`) must be installed and authenticated where Terraform runs.
- The `hashicorp/null` provider (~> 3.0) is required.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.7.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.59.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group_member.group_members](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member) | resource |
| [azurerm_role_assignment.group_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [null_resource.admin_owner](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
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
