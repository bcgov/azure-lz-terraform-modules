variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the Resource Group where the Network Function Azure Traffic Collector should exist."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the Azure Region where the Network Function Azure Traffic Collector should exist."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Network Function Azure Traffic Collector."
  type        = map(string)
  default     = null  
}
