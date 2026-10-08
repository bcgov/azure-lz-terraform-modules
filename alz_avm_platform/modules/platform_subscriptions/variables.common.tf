variable "location" {
  type        = string
  description = "The default location for resources in these Subscriptions."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Controls telemetry collection for subscription vending. Set to false to omit User-Agent headers."
  nullable    = false
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = ""
}
