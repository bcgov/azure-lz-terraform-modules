variable "user_assigned_identity_name" {
  description = "(Required) Specifies the name of this User Assigned Identity."
  type        = string
}

variable "location" {
  description = "(Required) The Azure Region where the User Assigned Identity should exist."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the User Assigned Identity should exist."
  type        = string
}
