#------------------------------------------------------------------------------
# Alerting Variables
#------------------------------------------------------------------------------

variable "teams_webhook_url" {
  type        = string
  description = "The Microsoft Teams incoming webhook URL for alert notifications."
  sensitive   = true
}

variable "cloud_team_email" {
  type        = string
  description = "The email address for the Cloud Team (fallback for alerts)."

  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.cloud_team_email))
    error_message = "Cloud team email must be a valid email address."
  }
}

variable "jira_base_url" {
  type        = string
  description = "The base URL for the Jira instance (e.g., https://bcgov.atlassian.net)."
}

variable "jira_user_email" {
  type        = string
  description = "The email address of the Jira API user."
}

variable "jira_api_token" {
  type        = string
  description = "The Jira API token for authentication."
  sensitive   = true
}

variable "jira_project_key" {
  type        = string
  description = "The Jira project key for creating incidents (e.g., MCCS)."
}

variable "jira_issue_type" {
  type        = string
  description = "The Jira issue type for auto-created incidents."
  default     = "Incident"
}

variable "enable_alerting" {
  type        = bool
  description = "Whether to enable alerting infrastructure (Action Groups, Alert Rules, Logic App)."
  default     = true
}

#------------------------------------------------------------------------------
# Alert Thresholds
#------------------------------------------------------------------------------

variable "bgp_availability_threshold" {
  type        = number
  description = "BGP availability percentage threshold for critical alerts."
  default     = 100

  validation {
    condition     = var.bgp_availability_threshold >= 0 && var.bgp_availability_threshold <= 100
    error_message = "BGP availability threshold must be between 0 and 100."
  }
}

variable "arp_availability_threshold" {
  type        = number
  description = "ARP availability percentage threshold for critical alerts."
  default     = 100

  validation {
    condition     = var.arp_availability_threshold >= 0 && var.arp_availability_threshold <= 100
    error_message = "ARP availability threshold must be between 0 and 100."
  }
}

variable "bandwidth_warning_threshold" {
  type        = number
  description = "Bandwidth utilization percentage threshold for warning alerts."
  default     = 80

  validation {
    condition     = var.bandwidth_warning_threshold >= 0 && var.bandwidth_warning_threshold <= 100
    error_message = "Bandwidth warning threshold must be between 0 and 100."
  }
}

variable "bandwidth_critical_threshold" {
  type        = number
  description = "Bandwidth utilization percentage threshold for critical alerts."
  default     = 95

  validation {
    condition     = var.bandwidth_critical_threshold >= 0 && var.bandwidth_critical_threshold <= 100
    error_message = "Bandwidth critical threshold must be between 0 and 100."
  }
}

variable "alert_evaluation_frequency" {
  type        = string
  description = "How often alert rules are evaluated."
  default     = "PT5M"
}

variable "alert_window_size" {
  type        = string
  description = "The time window for alert evaluation."
  default     = "PT5M"
}
