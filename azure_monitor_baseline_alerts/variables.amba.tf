variable "management_subscription_id" {
  description = "Management subscription ID"
  type        = string
  default     = ""
}

variable "location" {
  description = "Location"
  type        = string
  default     = "canadacentral"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-amba-monitoring-001"
  description = "The resource group where the resources will be deployed."
}

variable "user_assigned_managed_identity_name" {
  type        = string
  default     = "id-amba-prod-001"
  description = "The name of the user-assigned managed identity."
}

variable "bring_your_own_user_assigned_managed_identity" {
  type        = bool
  default     = false
  description = "Flag to indicate if the user-assigned managed identity is provided by the user."
}

variable "bring_your_own_user_assigned_managed_identity_resource_id" {
  type        = string
  default     = ""
  description = "The resource ID of the user-assigned managed identity."
}

variable "action_group_email" {
  description = "Action group email"
  type        = list(string)
  default     = []
}

variable "action_group_arm_role_id" {
  description = "Action group ARM role ID"
  type        = list(string)
  default     = []
}

variable "logic_app_resource_id" {
  type        = string
  default     = ""
  description = "The resource ID of the logic app."
}

variable "logic_app_callback_url" {
  type        = string
  default     = ""
  description = "The callback URL of the logic app."
}

variable "event_hub_resource_id" {
  type        = list(string)
  default     = []
  description = "The resource ID of the event hub."
}

variable "webhook_service_uri" {
  type        = list(string)
  default     = []
  description = "The service URI of the webhook."
}

variable "function_resource_id" {
  type        = string
  default     = ""
  description = "The resource ID of the Azure function."
}

variable "function_trigger_uri" {
  type        = string
  default     = ""
  description = "The trigger URI of the Azure function."
}

variable "bring_your_own_alert_processing_rule_resource_id" {
  type        = string
  default     = ""
  description = "The resource id of the alert processing rule, required if you intend to use an existing alert processing rule for monitoring purposes."
}

variable "bring_your_own_action_group_resource_id" {
  type        = list(string)
  default     = []
  description = "The resource id of the action group, required if you intend to use an existing action group for monitoring purposes."
}

variable "amba_disable_tag_name" {
  type        = string
  default     = "MonitorDisable"
  description = "Tag name used to disable monitoring at the resource level."
}

variable "amba_disable_tag_values" {
  type        = list(string)
  default     = ["true", "Test", "Dev", "Sandbox"]
  description = "Tag value(s) used to disable monitoring at the resource level."
}

variable "tags" {
  type = map(string)
  default = {
    _deployed_by_amba = "True"
  }
  description = "(Optional) Tags of the resource."
}
