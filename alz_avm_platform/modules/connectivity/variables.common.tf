variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
  default     = ""
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = ""
}

variable "location" {
  description = "(Required) The Azure Region where the resource should exist."
  type        = string
}

variable "tags" {
  description = "(Optional) Tags of the resource."
  type        = map(string)
  default     = null
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Controls telemetry collection for the AVM modules. Set to false to omit User-Agent headers."
  nullable    = false
}
