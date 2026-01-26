variable "subscription_id_management" {
  description = "(Required) Subscription ID to use for \"management\" resources."
  type        = string
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "environment" {
  description = "(Optional) Which Azure environment to deploy to. Options are: forge, or live."
  type        = string
}

variable "location" {
  description = "(Required) Azure region to deploy to. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["canada central", "canadacentral", "canada east", "canadaeast"], lower(var.location))
    error_message = "ERROR: Only Canadian Azure Regions are allowed! Valid values for the variable \"location\" are: \"canadaeast\",\"canadacentral\"."
  }
}

variable "tags" {
  description = "(Optional) A map of tags to add to the resources"
  type        = map(string)
  default     = null
}