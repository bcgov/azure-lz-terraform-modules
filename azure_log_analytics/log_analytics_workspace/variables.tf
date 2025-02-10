variable "location" {
  description = "(Required) The Azure Region where the Log Analytics Workspace should exist."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the Log Analytics Workspace should exist."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = null
}
