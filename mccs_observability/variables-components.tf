#------------------------------------------------------------------------------
# Component Configuration Variables
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Log Analytics
#------------------------------------------------------------------------------

variable "log_analytics_sku" {
  type        = string
  description = "The SKU for Log Analytics Workspace."
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  type        = number
  description = "The number of days to retain logs in Log Analytics."
  default     = 90

  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

variable "enable_activity_log_diagnostics" {
  type        = bool
  description = "Whether to route subscription activity logs (administrative changes, service/resource health, policy) to the Log Analytics workspace."
  default     = true
}

variable "activity_log_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID used by the Platform Changes dashboard. Defaults to this module's workspace. Point this at the CAF/platform workspace when activity logs are already shipped there."
  default     = null
}

#------------------------------------------------------------------------------
# Key Vault
#------------------------------------------------------------------------------

variable "key_vault_sku" {
  type        = string
  description = "The SKU for Key Vault."
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be standard or premium."
  }
}

variable "key_vault_soft_delete_retention_days" {
  type        = number
  description = "The number of days for Key Vault soft delete retention."
  default     = 90

  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Key Vault soft delete retention must be between 7 and 90 days."
  }
}

#------------------------------------------------------------------------------
# Grafana
#------------------------------------------------------------------------------

variable "grafana_sku" {
  type        = string
  description = "The SKU for Azure Managed Grafana."
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Essential"], var.grafana_sku)
    error_message = "Grafana SKU must be Standard or Essential."
  }
}

variable "grafana_zone_redundancy" {
  type        = bool
  description = "Whether to enable zone redundancy for Grafana."
  default     = true
}

variable "grafana_public_network_access" {
  type        = bool
  description = "Whether to enable public network access to Grafana."
  default     = false
}

variable "grafana_api_key_enabled" {
  type        = bool
  description = "Whether to enable API key authentication for Grafana."
  default     = true
}

variable "grafana_deterministic_outbound_ip" {
  type        = bool
  description = "Whether to enable deterministic outbound IP for Grafana."
  default     = true
}

variable "enable_grafana_dashboards" {
  type        = bool
  description = "Whether to provision Grafana dashboards via Terraform."
  default     = true
}

variable "grafana_service_account_token" {
  type        = string
  description = "Grafana service account token for dashboard provisioning. Optional: when omitted, the module reads the grafana-service-account-token secret from the module's Key Vault instead."
  default     = ""
  sensitive   = true
}

variable "create_grafana_service_account" {
  type        = bool
  description = "Whether to also create a Grafana service account through the Grafana API. The API needs an existing token, so the first bootstrap must be done manually in the Grafana UI; keep false once the token is provided."
  default     = false
}

#------------------------------------------------------------------------------
# Jump Box
#------------------------------------------------------------------------------

variable "deploy_jumpbox" {
  type        = bool
  description = "Whether to deploy a Windows jump box for accessing private resources."
  default     = false
}

variable "jumpbox_vm_size" {
  type        = string
  description = "The VM size for the jump box."
  default     = "Standard_B2s"
}

variable "jumpbox_admin_username" {
  type        = string
  description = "The administrator username for the jump box."
  default     = "azureadmin"
}

variable "jumpbox_enable_aad_login" {
  type        = bool
  description = "Whether to enable Entra ID (AAD) login for the jump box."
  default     = true
}
