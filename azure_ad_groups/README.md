# azure_ad_groups

Creates Azure AD groups (Owners, Contributors, Readers) for a project set and assigns them roles at the given scope.

## Group owners behaviour

Groups always include the **Terraform execution identity** and the current **admin email** user as owners.

**Key behaviour:**

- **Current owners are preserved** - Existing owners already on the group are read and merged into the desired owner list.
- **`admin_email` is re-added if the user exists** - If the current admin user exists in Entra ID and is removed outside Terraform, the next plan/apply adds them back.
- **Missing `admin_email` users are ignored** - If the configured `admin_email` does not resolve to an Entra user, the module skips that owner rather than failing the user lookup.
- **Portal-added owners are preserved** - Owners added outside Terraform remain owners because the module merges them into the desired owner set rather than replacing them.

**Admin change behaviour:** If `admin_email` changes, the new admin is added automatically. The previous admin may remain as an owner and can be removed manually if desired.

**Requirements:**

- Azure CLI (`az`) must be installed and authenticated where Terraform runs.
- The `hashicorp/null` provider (~> 3.0) is required.

## Group members behaviour

Group members are managed in an **add-only** manner using Azure CLI calls from Terraform.

**Key behaviour:**

- **Pre-existing members are preserved** - If a desired user is already a direct member of the target group, Terraform detects that and skips the add.
- **Missing desired members are added** - If a desired user is not yet a member, Terraform adds them during apply.
- **Members are not removed automatically** - Removing a user from module inputs does not remove them from the Entra group.

This avoids failures when memberships already exist in Entra ID but were never imported into Terraform state.

**Migration note:**

If you previously used the `azuread_group_member` resource version of this module, remove those membership instances from Terraform state before applying this version. Otherwise Terraform will plan to destroy the old `azuread_group_member` resources as part of the transition to `null_resource.group_members`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_group.groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azurerm_role_assignment.group_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [null_resource.group_members](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_group.existing](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azuread_groups.existing](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/groups) | data source |
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
