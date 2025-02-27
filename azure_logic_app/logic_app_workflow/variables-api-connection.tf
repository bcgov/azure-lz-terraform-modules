variable "api_connection_name" {
  description = "(Required) The Name which should be used for this API Connection."
  type        = string
}

variable "api_connection_display_name" {
  description = "(Optional) A display name for this API Connection."
  type        = string
  default     = null
}

variable "jira_api_username" {
  description = "(Required) The username for the Jira API."
  type        = string
}

variable "jira_api_token" {
  description = "(Required) The API token for the Jira API."
  type        = string
  sensitive   = true
  # Use export TF_VAR_jira_api_token="your-jira-api"
}
