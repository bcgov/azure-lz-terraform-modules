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
# PostgreSQL
#------------------------------------------------------------------------------

variable "postgresql_version" {
  type        = string
  description = "The version of PostgreSQL to deploy."
  default     = "15"

  validation {
    condition     = contains(["14", "15", "16"], var.postgresql_version)
    error_message = "PostgreSQL version must be 14, 15, or 16."
  }
}

variable "postgresql_sku_name" {
  type        = string
  description = "The SKU name for PostgreSQL Flexible Server."
  default     = "GP_Standard_D2s_v3"
}

variable "postgresql_storage_mb" {
  type        = number
  description = "The storage size in MB for PostgreSQL."
  default     = 32768 # 32 GB
}

variable "postgresql_backup_retention_days" {
  type        = number
  description = "The number of days to retain PostgreSQL backups."
  default     = 35

  validation {
    condition     = var.postgresql_backup_retention_days >= 7 && var.postgresql_backup_retention_days <= 35
    error_message = "PostgreSQL backup retention must be between 7 and 35 days."
  }
}

variable "postgresql_geo_redundant_backup" {
  type        = bool
  description = "Whether to enable geo-redundant backups for PostgreSQL."
  default     = true
}

variable "postgresql_high_availability" {
  type        = bool
  description = "Whether to enable zone-redundant high availability for PostgreSQL."
  default     = true
}

variable "postgresql_admin_username" {
  type        = string
  description = "The administrator username for PostgreSQL."
  default     = "pgadmin"
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
  description = "Service account token for Grafana API authentication. Required when enable_grafana_dashboards is true."
  default     = ""
  sensitive   = true
}

variable "create_grafana_service_account" {
  type        = bool
  description = "Whether to create a Grafana service account for Terraform automation. Set to true on first deployment, then false after token is stored."
  default     = false
}

#------------------------------------------------------------------------------
# Container Instances (Netbox/Prometheus)
#------------------------------------------------------------------------------

variable "netbox_image" {
  type        = string
  description = "The Docker image for Netbox."
  default     = "netboxcommunity/netbox:v3.7"
}

variable "netbox_cpu" {
  type        = number
  description = "The number of CPU cores for Netbox container."
  default     = 1
}

variable "netbox_memory" {
  type        = number
  description = "The memory in GB for Netbox container."
  default     = 2
}

variable "prometheus_image" {
  type        = string
  description = "The Docker image for Prometheus."
  default     = "prom/prometheus:v2.48.0"
}

variable "prometheus_cpu" {
  type        = number
  description = "The number of CPU cores for Prometheus container."
  default     = 1
}

variable "prometheus_memory" {
  type        = number
  description = "The memory in GB for Prometheus container."
  default     = 2
}

variable "prometheus_retention_days" {
  type        = number
  description = "The number of days to retain Prometheus metrics."
  default     = 15
}

variable "redis_image" {
  type        = string
  description = "The Docker image for Redis (Netbox cache)."
  default     = "redis:7-alpine"
}

variable "netbox_admin_email" {
  type        = string
  description = "The email address for the Netbox admin user."
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
