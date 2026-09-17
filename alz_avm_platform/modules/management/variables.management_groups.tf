### Required variables ###
variable "architecture_name" {
  type        = string
  description = "ALZ architecture definition name in ./lib."
  default     = "var_alz_custom"
}

variable "location" {
  type        = string
  description = "The default location for resources in this management group. Used for policy managed identities."
}

variable "parent_resource_id" {
  type        = string
  description = "Parent management group name. Leave empty to target tenant root group."
  default     = ""

  validation {
    condition     = var.parent_resource_id == "" || !strcontains(var.parent_resource_id, "/")
    error_message = "parent_resource_id must be a management group name (no slashes)."
  }
}

### Optional variables ###

variable "subscription_placement_destroy_behavior" {
  type        = string
  description = "The destroy behavior for subscription placements. Valid values are 'default', 'parent', 'intermediate_root' or 'custom'."
  default     = "parent"
}

variable "policy_default_values" {
  type        = map(string)
  default     = {}
  description = "Policy default values to apply while resolving the Azure Landing Zones library. Each value must be JSON containing a value property."
}

variable "policy_assignments_to_modify" {
  type = map(object({
    policy_assignments = map(object({
      enforcement_mode = optional(string, null)
      identity         = optional(string, null)
      identity_ids     = optional(list(string), null)
      parameters       = optional(map(string), null)
      not_scopes       = optional(list(string), null)
      non_compliance_messages = optional(set(object({
        message                        = string
        policy_definition_reference_id = optional(string, null)
      })), null)
      resource_selectors = optional(list(object({
        name = string
        resource_selector_selectors = optional(list(object({
          kind   = string
          in     = optional(set(string), null)
          not_in = optional(set(string), null)
        })), [])
      })))
      overrides = optional(list(object({
        kind  = string
        value = string
        override_selectors = optional(list(object({
          kind   = string
          in     = optional(set(string), null)
          not_in = optional(set(string), null)
        })), [])
      })))
      creation_enabled = optional(bool, true)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
A map of policy assignment objects to modify the ALZ architecture with.
You only need to specify the properties you want to change.

The key is the id of the management group. The value is an object with a single attribute, `policy_assignments`.
The `policy_assignments` value is a map of policy assignments to modify.
The key of this map is the assignment name, and the value is an object with optional attributes for modifying the policy assignments.

- `enforcement_mode` - (Optional) The enforcement mode of the policy assignment. Possible values are `Default` and `DoNotEnforce`.
- `identity` - (Optional) The identity of the policy assignment. Possible values are `SystemAssigned` and `UserAssigned`.
- `identity_ids` - (Optional) A set of ids of the user assigned identities to assign to the policy assignment.
- `non_compliance_message` - (Optional) A set of non compliance message objects to use for the policy assignment. Each object has the following properties:
  - `message` - (Required) The non compliance message.
  - `policy_definition_reference_id` - (Optional) The reference id of the policy definition to use for the non compliance message.
- `parameters` - (Optional) The parameters to use for the policy assignment. The map key is the parameter name and the value is an JSON object containing a single `Value` attribute with the values to apply. This to mitigate issues with the Terraform type system. E.g. `{ defaultName = jsonencode({Value = \"value\"}) }`.
- `resource_selectors` - (Optional) A list of resource selector objects to use for the policy assignment. Each object has the following properties:
  - `name` - (Required) The name of the resource selector.
  - `selectors` - (Optional) A list of selector objects to use for the resource selector. Each object has the following properties:
    - `kind` - (Required) The kind of the selector. Allowed values are: `resourceLocation`, `resourceType`, `resourceWithoutLocation`. `resourceWithoutLocation` cannot be used in the same resource selector as `resourceLocation`.
    - `in` - (Optional) A set of strings to include in the selector.
    - `not_in` - (Optional) A set of strings to exclude from the selector.
- `overrides` - (Optional) A list of override objects to use for the policy assignment. Each object has the following properties:
  - `kind` - (Required) The kind of the override.
  - `value` - (Required) The value of the override. Supported values are policy effects: <https://learn.microsoft.com/azure/governance/policy/concepts/effects>.
  - `selectors` - (Optional) A list of selector objects to use for the override. Each object has the following properties:
    - `kind` - (Required) The kind of the selector.
    - `in` - (Optional) A set of strings to include in the selector.
    - `not_in` - (Optional) A set of strings to exclude from the selector.
- `creation_enabled` - (Optional) Whether the policy assignment is created or not. Defaults to `true`. IMPORTANT: This is a convenience property for very small scale deployments, the recommended approach is to update your custom library to exclude the policy assignment.

DESCRIPTION
}
