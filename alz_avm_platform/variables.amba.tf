variable "amba_resource_group_name" {
  type        = string
  default     = "rg-amba-monitoring-001"
  description = "The resource group where the resources will be deployed."
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
