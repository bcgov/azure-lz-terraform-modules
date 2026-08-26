variable "architecture_name" {
  type        = string
  description = "ALZ architecture definition name in ./lib."
  default     = "var_alz_custom"
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

variable "subscription_placement_destroy_behavior" {
  type        = string
  description = "The destroy behavior for subscription placements. Valid values are 'default', 'parent', 'intermediate_root' or 'custom'."
  default     = "parent"
}
