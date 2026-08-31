variable "network_manager_name" {
  description = "(Required) Specifies the name which should be used for this Network Manager. Changing this forces a new Network Manager to be created."
  type        = string
}

variable "scope" {
  description = "(Required) Specifies the scope of the Network Manager. Changing this forces a new Network Manager to be created. At least one of the nested `management_group_ids` or `subscription_ids` attributes must be set."
  type = object({
    management_group_ids = optional(list(string), null)
    subscription_ids     = optional(list(string), null)
  })
  nullable = false

  validation {
    condition     = length(coalesce(var.scope.management_group_ids, [])) > 0 || length(coalesce(var.scope.subscription_ids, [])) > 0
    error_message = "At least one of `scope.management_group_ids` or `scope.subscription_ids` must be specified with a non-empty list."
  }
}

variable "scope_accesses" {
  description = "(Optional) A list of configuration deployment types. Possible values are Connectivity, SecurityAdmin and Routing, which specify whether Connectivity Configuration, Security Admin Configuration or Routing Configuration are allowed for the Network Manager."
  type        = list(string)
  default     = null

  validation {
    condition     = var.scope_accesses == null ? true : alltrue([for value in var.scope_accesses : contains(["Connectivity", "SecurityAdmin", "Routing"], value)])
    error_message = "scope_accesses must be one of Connectivity, SecurityAdmin or Routing."
  }
}

variable "description" {
  description = "(Optional) A description of the Network Manager."
  type        = string
  default     = null
}
