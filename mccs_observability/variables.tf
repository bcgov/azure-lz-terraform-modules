#------------------------------------------------------------------------------
# Common Variables
#------------------------------------------------------------------------------

variable "subscription_id_connectivity" {
  type        = string
  description = "The subscription ID for the connectivity subscription where resources will be deployed."
  default     = null
}

variable "subscription_id_management" {
  type        = string
  description = "The subscription ID for the management subscription."
  default     = null
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., prod, dev, staging)."

  validation {
    condition     = contains(["prod", "dev", "staging", "test"], var.environment)
    error_message = "Environment must be one of: prod, dev, staging, test."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where resources will be deployed."
  default     = "canadacentral"

  validation {
    condition     = contains(["canadacentral", "canadaeast"], var.location)
    error_message = "Location must be canadacentral or canadaeast."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources."
  default     = null
}

#------------------------------------------------------------------------------
# Resource Naming Overrides (optional)
#------------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Override for the resource group name. If not provided, a name will be generated."
  default     = null
}

variable "key_vault_name" {
  type        = string
  description = "Override for the Key Vault name. If not provided, a name will be generated."
  default     = null

  validation {
    condition     = var.key_vault_name == null || (length(var.key_vault_name) >= 3 && length(var.key_vault_name) <= 24)
    error_message = "Key Vault name must be between 3 and 24 characters."
  }
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Override for the Log Analytics Workspace name. If not provided, a name will be generated."
  default     = null
}

variable "grafana_name" {
  type        = string
  description = "Override for the Azure Managed Grafana name. If not provided, a name will be generated."
  default     = null
}

variable "postgresql_server_name" {
  type        = string
  description = "Override for the PostgreSQL Flexible Server name. If not provided, a name will be generated."
  default     = null
}

variable "storage_account_name" {
  type        = string
  description = "Override for the Storage Account name. If not provided, a name will be generated."
  default     = null

  validation {
    condition     = var.storage_account_name == null || (length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24)
    error_message = "Storage Account name must be between 3 and 24 characters."
  }
}

variable "action_group_name" {
  type        = string
  description = "Override for the Action Group name. If not provided, a name will be generated."
  default     = null
}

variable "logic_app_name" {
  type        = string
  description = "Override for the Logic App name. If not provided, a name will be generated."
  default     = null
}
