variable "resource_group_name" {
  description = "The name of the resource group in which the Logic App will be created."
  type        = string
}

variable "location" {
  description = "The location in which the Logic App will be created."
  type        = string

  validation {
    condition     = contains(["canada central", "canadacentral", "canada east", "canadaeast"], lower(var.location))
    error_message = "The location must be either Canada Central or Canada East."
  }
}
