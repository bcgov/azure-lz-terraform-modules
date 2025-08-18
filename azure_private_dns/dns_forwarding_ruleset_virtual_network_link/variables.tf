# // MARK: Common Variables
# variable "location" {
#   description = "(Required) Azure region to deploy to. Changing this forces a new resource to be created."
#   type        = string

#   validation {
#     condition     = contains(["Canada Central", "canadacentral", "Canada East", "canadaeast"], var.location)
#     error_message = "ERROR: Only Canadian Azure Regions are allowed! Valid values for the variable \"location\" are: \"canadaeast\",\"canadacentral\"."
#   }
# }

variable "subscription_id_connectivity" {
  description = "(Required) Subscription ID to use for \"connectivity\" resources."
  type        = string
}
