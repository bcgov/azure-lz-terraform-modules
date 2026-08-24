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
