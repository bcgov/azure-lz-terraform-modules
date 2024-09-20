variable "subscription_id_management" {
  description = "(Required) Subscription ID to use for \"management\" resources."
  type        = string
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = null
}