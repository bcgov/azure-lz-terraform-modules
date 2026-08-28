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
| <a name="input_policy_assignments_to_modify"></a> [policy\_assignments\_to\_modify](#input\_policy\_assignments\_to\_modify) | A map of policy assignment objects to modify the ALZ architecture with.<br/>You only need to specify the properties you want to change.<br/><br/>The key is the id of the management group. The value is an object with a single attribute, `policy_assignments`.<br/>The `policy_assignments` value is a map of policy assignments to modify.<br/>The key of this map is the assignment name, and the value is an object with optional attributes for modifying the policy assignments.<br/><br/>- `enforcement_mode` - (Optional) The enforcement mode of the policy assignment. Possible values are `Default` and `DoNotEnforce`.<br/>- `identity` - (Optional) The identity of the policy assignment. Possible values are `SystemAssigned` and `UserAssigned`.<br/>- `identity_ids` - (Optional) A set of ids of the user assigned identities to assign to the policy assignment.<br/>- `non_compliance_message` - (Optional) A set of non compliance message objects to use for the policy assignment. Each object has the following properties:<br/>  - `message` - (Required) The non compliance message.<br/>  - `policy_definition_reference_id` - (Optional) The reference id of the policy definition to use for the non compliance message.<br/>- `parameters` - (Optional) The parameters to use for the policy assignment. The map key is the parameter name and the value is an JSON object containing a single `Value` attribute with the values to apply. This to mitigate issues with the Terraform type system. E.g. `{ defaultName = jsonencode({Value = \"value\"}) }`.<br/>- `resource_selectors` - (Optional) A list of resource selector objects to use for the policy assignment. Each object has the following properties:<br/>  - `name` - (Required) The name of the resource selector.<br/>  - `selectors` - (Optional) A list of selector objects to use for the resource selector. Each object has the following properties:<br/>    - `kind` - (Required) The kind of the selector. Allowed values are: `resourceLocation`, `resourceType`, `resourceWithoutLocation`. `resourceWithoutLocation` cannot be used in the same resource selector as `resourceLocation`.<br/>    - `in` - (Optional) A set of strings to include in the selector.<br/>    - `not_in` - (Optional) A set of strings to exclude from the selector.<br/>- `overrides` - (Optional) A list of override objects to use for the policy assignment. Each object has the following properties:<br/>  - `kind` - (Required) The kind of the override.<br/>  - `value` - (Required) The value of the override. Supported values are policy effects: <https://learn.microsoft.com/azure/governance/policy/concepts/effects>.<br/>  - `selectors` - (Optional) A list of selector objects to use for the override. Each object has the following properties:<br/>    - `kind` - (Required) The kind of the selector.<br/>    - `in` - (Optional) A set of strings to include in the selector.<br/>    - `not_in` - (Optional) A set of strings to exclude from the selector.<br/>- `creation_enabled` - (Optional) Whether the policy assignment is created or not. Defaults to `true`. IMPORTANT: This is a convenience property for very small scale deployments, the recommended approach is to update your custom library to exclude the policy assignment. | <pre>map(object({<br/>    policy_assignments = map(object({<br/>      enforcement_mode = optional(string, null)<br/>      identity         = optional(string, null)<br/>      identity_ids     = optional(list(string), null)<br/>      parameters       = optional(map(string), null)<br/>      not_scopes       = optional(list(string), null)<br/>      non_compliance_messages = optional(set(object({<br/>        message                        = string<br/>        policy_definition_reference_id = optional(string, null)<br/>      })), null)<br/>      resource_selectors = optional(list(object({<br/>        name = string<br/>        resource_selector_selectors = optional(list(object({<br/>          kind   = string<br/>          in     = optional(set(string), null)<br/>          not_in = optional(set(string), null)<br/>        })), [])<br/>      })))<br/>      overrides = optional(list(object({<br/>        kind  = string<br/>        value = string<br/>        override_selectors = optional(list(object({<br/>          kind   = string<br/>          in     = optional(set(string), null)<br/>          not_in = optional(set(string), null)<br/>        })), [])<br/>      })))<br/>      creation_enabled = optional(bool, true)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_policy_default_values"></a> [policy\_default\_values](#input\_policy\_default\_values) | Policy default values to apply while resolving the Azure Landing Zones library. Each value must be JSON containing a value property. | `map(string)` | `{}` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | `""` | no |
| <a name="input_subscription_placement_destroy_behavior"></a> [subscription\_placement\_destroy\_behavior](#input\_subscription\_placement\_destroy\_behavior) | The destroy behavior for subscription placements. Valid values are 'default', 'parent', 'intermediate\_root' or 'custom'. | `string` | `"parent"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_resource_ids"></a> [management\_group\_resource\_ids](#output\_management\_group\_resource\_ids) | A map of management group names to their resource ids. |
<!-- END_TF_DOCS -->
