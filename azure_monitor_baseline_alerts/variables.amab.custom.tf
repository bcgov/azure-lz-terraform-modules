## These are custom variables for the Azure Monitor Baseline Alerts module that deviate from the default definition.

variable "root_management_group_name" {
  description = "The name of the root management group."
  type        = string
}

variable "architecture_name" {
  description = "The name of the architecture."
  type        = string
}

variable "parent_resource_id" {
  description = "The parent resource ID for the architecture."
  type        = string
}
