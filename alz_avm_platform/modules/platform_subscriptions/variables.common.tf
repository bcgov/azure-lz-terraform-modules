variable "location" {
  type        = string
  description = "The default location for resources in these Subscriptions."
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = ""
}
