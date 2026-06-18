variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
}

variable "primary_location" {
  description = "The primary location for resources"
  type        = string
  default     = "canadacentral"
}

variable "secondary_location" {
  description = "The secondary location for resources"
  type        = string
  default     = "canadaeast"
}

variable "environment" {
  description = "(Required) Which Azure environment to deploy to. Options are: LIVE or FORGE."
  type        = string

  validation {
    condition     = contains(["LIVE", "FORGE"], upper(var.environment))
    error_message = "ERROR: Only LIVE or FORGE are allowed for the variable \"environment\"."
  }
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
