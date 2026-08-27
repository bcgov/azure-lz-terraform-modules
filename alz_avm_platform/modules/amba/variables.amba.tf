variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "description" {
  type        = string
  default     = "_deployed_by_amba"
  description = "The description used for the role assignment to identify the resource as deployed by AMBA."
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "amba_resource_group_name" {
  type        = string
  default     = "rg-amba-monitoring-001"
  description = "The resource group where the resources will be deployed."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on the resource group. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

variable "amba_role_definition_id" {
  type        = string
  default     = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
  description = "The role definition ID to assign to the User Assigned Managed Identity. Defaults to Monitoring Reader."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "amba_user_assigned_managed_identity_name" {
  type        = string
  default     = "id-amba-prod-001"
  description = "The name of the user-assigned managed identity."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{1,126}[a-zA-Z0-9]$", var.amba_user_assigned_managed_identity_name))
    error_message = "The resource name must start with a letter or number, have a length between 3 and 128 characters and can only contain a combination of alphanumeric characters, hyphens and underscores."
  }
}
