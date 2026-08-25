# management_groups

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12, < 2.0 |
| <a name="requirement_alz"></a> [alz](#requirement\_alz) | ~> 0.21 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.4 |
| <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) | ~> 0.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alz"></a> [alz](#module\_alz) | Azure/avm-ptn-alz/azurerm | ~> 0.21.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture_name"></a> [architecture\_name](#input\_architecture\_name) | ALZ architecture definition name in ./lib. | `string` | `"var_alz_custom"` | no |
| <a name="input_location"></a> [location](#input\_location) | The default location for resources in this management group. Used for policy managed identities. | `string` | n/a | yes |
| <a name="input_parent_resource_id"></a> [parent\_resource\_id](#input\_parent\_resource\_id) | Parent management group name. Leave empty to target tenant root group. | `string` | `""` | no |
| <a name="input_subscription_placement_destroy_behavior"></a> [subscription\_placement\_destroy\_behavior](#input\_subscription\_placement\_destroy\_behavior) | The destroy behavior for subscription placements. Valid values are 'default', 'parent', 'intermediate\_root' or 'custom'. | `string` | `"parent"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_resource_ids"></a> [management\_group\_resource\_ids](#output\_management\_group\_resource\_ids) | A map of management group names to their resource ids. |
| <a name="output_policy_role_assignment_resource_ids"></a> [policy\_role\_assignment\_resource\_ids](#output\_policy\_role\_assignment\_resource\_ids) | A map of policy role assignments to their resource ids. |
<!-- END_TF_DOCS -->
