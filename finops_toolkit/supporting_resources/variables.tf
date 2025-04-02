variable "IPAM_TOKEN" {
  description = "(Required) The IPAM token to use for IP address management."
  type        = string
  sensitive   = true
  # az account get-access-token --resource api://8b672441-25f3-4a33-8336-d853c466a782
  # For local testing, add the IPAM token to an environment variable using: export TF_VAR_IPAM_TOKEN="<ACCESS_TOKEN_VALUE>"
}

variable "environment" {
  description = "(Required) This is either LIVE or FORGE."
  type        = string

  validation {
    condition     = contains(["LIVE", "FORGE"], var.environment)
    error_message = "ERROR: Only LIVE or FORGE are allowed for the variable \"environment\"."
  }
}

variable "subscription_id_management" {
  description = "(Required) Subscription ID to use for \"management\" resources."
  type        = string
}
