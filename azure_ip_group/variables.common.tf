variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "resource_group_name" {
  description = "The resource group where the resources will be deployed."
  type        = string
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}
