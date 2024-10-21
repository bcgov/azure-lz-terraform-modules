// MARK: Identity

variable "user_assigned_identity_name" {
  description = "(Required) Specifies the name of this User Assigned Identity."
  type        = string
}


// MARK: Key Vault
variable "key_vault_name" {
  description = "(Required) Specifies the name of the Key Vault Key."
  type        = string

  validation {
    condition     = length(var.key_vault_name) <= 24
    error_message = "The Key Vault name must be between 3 and 24 characters in length."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Key Vault."
  type        = string
}

variable "sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The SKU name must be either 'standard' or 'premium'."
  }
}

variable "enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "(Optional) A network_acls block as defined below."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "The soft delete retention days must be at least 7 days."
  }
}

variable "contacts" {
  description = "(Optional) One or more contact block as defined below."
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = []
}


// MARK: Key Vault Access Policy
variable "application_id" {
  description = "(Optional) The object ID of an Application in Azure Active Directory."
  type        = string
  default     = null
}

variable "certificate_permissions" {
  description = "(Optional) List of certificate permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.certificate_permissions : contains(["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"], permission)
    ])
    error_message = "certificate_permissions must be one or more from the following: Backup, Create, Delete, DeleteIssuers, Get, GetIssuers, Import, List, ListIssuers, ManageContacts, ManageIssuers, Purge, Recover, Restore, SetIssuers and Update."
  }
}

variable "key_permissions" {
  description = "(Optional) List of key permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.key_permissions : contains(["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"], permission)
    ])
    error_message = "key_permissions must be one or more from the following: Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify, WrapKey, Release, Rotate, GetRotationPolicy and SetRotationPolicy."
  }
}

variable "secret_permissions" {
  description = "(Optional) List of secret permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.secret_permissions : contains(["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"], permission)
    ])
    error_message = "secret_permissions must be one or more from the following: Backup, Delete, Get, List, Purge, Recover, Restore and Set."
  }
}

variable "storage_permissions" {
  description = "(Optional) List of storage permissions."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for permission in var.storage_permissions : contains(["Backup", "Delete", "Deletesas", "Get", "Getsas", "List", "Listsas", "Purge", "Recover", "Regeneratekey", "Restore", "Set", "Setsas", "Update"], permission)
    ])
    error_message = "storage_permissions must be one or more from the following: Backup, Delete, Deletesas, Get, Getsas, List, Listsas, Purge, Recover, Regeneratekey, Restore, Set, Setsas and Update."
  }
}


// MARK: Key Vault Certificate
variable "certificate_name" {
  description = "(Required) Specifies the name of the Key Vault Certificate."
  type        = string
}

variable "certificate" {
  description = "(Optional) A certificate block as defined below, used to Import an existing certificate."
  type = object({
    contents = string
    password = optional(string)
  })
}


// MARK: Firewall Policy
variable "base_firewall_policy_name" {
  description = "(Required) The name which should be used for the parent Firewall Policy."
  type        = string
}

variable "lz_firewall_policy_name" {
  description = "(Required) The name which should be used for the child Firewall Policy."
  type        = string
}

variable "base_policy_id" {
  description = "(Optional) The ID of the base Firewall Policy."
  type        = string
  default     = null
}

variable "dns" {
  description = "(Optional) A dns block as defined below."
  type = object({
    proxy_enabled = optional(bool)
    servers       = optional(list(string))
  })
  default = null
}

variable "identity" {
  description = "(Optional) An identity block as defined below."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "insights" {
  description = "(Optional) An insights block as defined below."
  type = object({
    enabled                            = bool
    default_log_analytics_workspace_id = string
    retention_in_days                  = optional(number)
    log_analytics_workspace = optional(list(object({
      id                = string
      firewall_location = string
    })))
  })
  default = null
}

variable "intrusion_detection" {
  description = "(Optional) A intrusion_detection block as defined below."
  type = object({
    mode = string
    signature_overrides = optional(list(object({
      id    = optional(number)
      state = optional(string)
    })))
    traffic_bypass = optional(list(object({
      name                  = string
      protocol              = string
      description           = optional(string)
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_ports     = optional(list(string))
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
    })))
    private_ranges = optional(list(string))
  })
  default = null
}

variable "private_ip_ranges" {
  description = "(Optional) A list of private IP ranges to which traffic will not be SNAT."
  type        = list(string)
  default     = null
}

variable "auto_learn_private_ranges_enabled" {
  description = "(Optional) Whether enable auto learn private IP range."
  type        = bool
  default     = null
}

variable "sku" {
  description = "(Optional) The SKU Tier of the Firewall Policy."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Invalid SKU Tier. Valid values are Basic, Standard and Premium."
  }
}

variable "threat_intelligence_allowlist" {
  description = "(Optional) A threat_intelligence_allowlist block as defined below."
  type = object({
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  })
  default = null
}

variable "threat_intelligence_mode" {
  description = "(Optional) The operation mode for Threat Intelligence."
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.threat_intelligence_mode)
    error_message = "Invalid Threat Intelligence Mode. Valid values are Alert, Deny and Off."
  }
}

variable "tls_certificate" {
  description = "(Optional) A tls_certificate block as defined below."
  type = object({
    key_vault_secret_id = string
    name                = string
  })
  default = null
}

variable "sql_redirect_allowed" {
  description = "(Optional) Whether SQL Redirect traffic filtering is allowed. Enabling this flag requires no rule using ports between 11000-11999."
  type        = bool
  default     = null
}

variable "explicit_proxy" {
  description = "(Optional) An explicit_proxy block as defined below."
  type = object({
    enabled         = optional(bool)
    http_port       = optional(number)
    https_port      = optional(number)
    enable_pac_file = optional(bool)
    pac_file_port   = optional(number)
    pac_file        = optional(string)
  })
  default = null
}


// MARK: Rule Collection Group
variable "base_firewall_policy_rule_collection_group" {
  description = "The Azure Firewall Policy Rule Collection Group."
  type = list(object({
    name     = string
    priority = number

    application_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number
      rule = list(object({
        name        = string
        description = optional(string)
        protocols = optional(list(object({
          type = string
          port = number
        })))
        http_headers = optional(list(object({
          name  = string
          value = string
        })))
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_urls      = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
        terminate_tls         = optional(bool)
        web_categories        = optional(list(string))
      }))
    })))

    network_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number

      rule = list(object({
        name                  = string
        description           = optional(string)
        protocols             = optional(list(string))
        destination_ports     = list(string)
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_ip_groups = optional(list(string))
        destination_fqdns     = optional(list(string))
      }))
    })))

    nat_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number

      rule = object({
        name                = string
        description         = optional(string)
        protocols           = list(string)
        source_addresses    = optional(list(string))
        source_ip_groups    = optional(list(string))
        destination_address = optional(string)
        destination_ports   = optional(list(string))
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = string
      })
    })))
  }))
  default = null
}

variable "lz_firewall_policy_rule_collection_group" {
  description = "The Azure Firewall Policy Rule Collection Group."
  type = list(object({
    name     = string
    priority = number

    application_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number
      rule = list(object({
        name        = string
        description = optional(string)
        protocols = optional(list(object({
          type = string
          port = number
        })))
        http_headers = optional(list(object({
          name  = string
          value = string
        })))
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_urls      = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
        terminate_tls         = optional(bool)
        web_categories        = optional(list(string))
      }))
    })))

    network_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number

      rule = list(object({
        name                  = string
        description           = optional(string)
        protocols             = optional(list(string))
        destination_ports     = list(string)
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_ip_groups = optional(list(string))
        destination_fqdns     = optional(list(string))
      }))
    })))

    nat_rule_collection = optional(list(object({
      name     = string
      action   = string
      priority = number

      rule = object({
        name                = string
        description         = optional(string)
        protocols           = list(string)
        source_addresses    = optional(list(string))
        source_ip_groups    = optional(list(string))
        destination_address = optional(string)
        destination_ports   = optional(list(string))
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = string
      })
    })))
  }))
  default = null
}
