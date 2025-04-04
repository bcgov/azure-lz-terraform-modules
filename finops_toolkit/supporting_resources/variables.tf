variable "IPAM_TOKEN" {
  description = "(Required) The IPAM token to use for IP address management."
  type        = string
  sensitive   = true
  # NOTE: --resource api:// value is environment specific (ie. FORGE vs LIVE).
  # For local testing, add the IPAM token to an environment variable using: export TF_VAR_IPAM_TOKEN="<ACCESS_TOKEN_VALUE>"
  # export TF_VAR_IPAM_TOKEN=$(az account get-access-token --resource api://### --query="accessToken" | tr -d '"')
}

variable "environment" {
  description = "(Required) This is either LIVE or FORGE."
  type        = string

  validation {
    condition     = contains(["LIVE", "FORGE"], var.environment)
    error_message = "ERROR: Only LIVE or FORGE are allowed for the variable \"environment\"."
  }
}

variable "location" {
  description = "(Required) Azure region to deploy to. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["Canada Central", "canadacentral", "Canada East", "canadaeast"], var.location)
    error_message = "ERROR: Only Canadian Azure Regions are allowed! Valid values for the variable \"location\" are: \"canadaeast\",\"canadacentral\"."
  }
}

variable "subscription_id_management" {
  description = "(Required) Subscription ID to use for \"management\" resources."
  type        = string
}

variable "tags" {
  description = "(Optional) A map of tags to assign to the resource. Tags are a set of key/value pairs."
  type        = map(string)
  default     = null
}
