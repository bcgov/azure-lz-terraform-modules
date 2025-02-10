variable "log_analytics_resource_group_name" {
  description = "(Required) The name of the resource group in which the Log Analytics Workspace should be created."
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace."
  type        = string

  validation {
    condition = (
      length(var.log_analytics_workspace_name) > 3 &&
      length(var.log_analytics_workspace_name) < 64 &&
      can(regex("^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*$",
      var.log_analytics_workspace_name))
    )
    error_message = "Workspace name should include 4-63 letters, digits or '-'. The '-' shouldn't be the first or the last symbol."
  }
}

variable "allow_resource_only_permissions" {
  description = "(Optional) Specifies if the log Analytics Workspace allow users accessing to data associated with resources they have permission to view, without permission to workspace."
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "(Optional) Specifies if the log Analytics workspace should enforce authentication using Azure AD."
  type        = bool
  default     = false
}

variable "log_analytics_sku" {
  description = "(Optional) The SKU of the Log Analytics Workspace."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "(Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
  type        = number

  validation {
    condition     = var.retention_in_days == 7 || (var.retention_in_days >= 30 && var.retention_in_days <= 730)
    error_message = "Retention in days should be either 7 (Free Tier only) or between 30 and 730."
  }
}

variable "daily_quota_gb" {
  description = "(Optional) The workspace daily quota for ingestion in GB. Defaults to -1 (unlimited) if omitted."
  type        = number
  default     = -1

  validation {
    condition     = var.log_analytics_sku == "Free" ? var.daily_quota_gb == 0.5 : true
    error_message = "Daily quota should be set to 0.5 when SKU is Free."
  }
}

variable "cmk_for_query_forced" {
  description = "(Optional) Is Customer Managed Storage mandatory for query management?"
  type        = bool
  default     = false
}

variable "log_analytics_identity" {
  description = "(Optional) A identity block as defined below."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "internet_ingestion_enabled" {
  description = "(Optional) Should the Log Analytics Workspace support ingestion over the Public Internet?"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "(Optional) Should the Log Analytics Workspace support querying over the Public Internet?"
  type        = bool
  default     = true
}

variable "reservation_capacity_in_gb_per_day" {
  description = "(Optional) The capacity reservation level in GB for this workspace."
  type        = number
  default     = null

  validation {
    condition     = var.log_analytics_sku == "CapacityReservation" ? contains([100, 200, 300, 400, 500, 1000, 2000, 5000], var.reservation_capacity_in_gb_per_day) : true
    error_message = "reservation_capacity_in_gb_per_day can only be used when the sku is set to CapacityReservation."
  }

  validation {
    condition     = var.log_analytics_sku == "CapacityReservation" ? var.reservation_capacity_in_gb_per_day != null : true
    error_message = "reservation_capacity_in_gb_per_day must be set when the sku is set to CapacityReservation."
  }
}

variable "data_collection_rule_id" {
  description = "(Optional) The ID of the Data Collection Rule to use for this workspace."
  type        = string
  default     = null
}

variable "immediate_data_purge_on_30_days_enabled" {
  description = "(Optional) Whether to remove the data in the Log Analytics Workspace immediately after 30 days."
  type        = bool
  default     = false
}
