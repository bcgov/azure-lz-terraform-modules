variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the ExpressRoute circuit."
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
  default     = null
}
