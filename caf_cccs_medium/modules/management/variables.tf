# Use variables to customize the deployment

variable "root_parent_id" {
  type        = string
  description = "Sets the value for the parent management group."
}

variable "root_id" {
  type        = string
  description = "Sets the value used for generating unique resource naming within the module."
}

variable "primary_location" {
  type        = string
  description = "Sets the location for \"primary\" resources to be created in."
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
}

variable "email_security_contact" {
  type        = string
  description = "Set a custom value for the security contact email address."
}

variable "log_retention_in_days" {
  type        = number
  description = "Set a custom value for how many days to store logs in the Log Analytics workspace."
}

variable "management_resources_tags" {
  type        = map(string)
  description = "Specify tags to add to \"management\" resources."
}

variable "log_analytics_workspace_settings" {
  type = object({
    sku                                = optional(string, null)
    reservation_capacity_in_gb_per_day = optional(number, null)
    retention_in_days                  = optional(number, null)
  })
  description = "Specify settings for the Log Analytics workspace."
  default     = null
}
