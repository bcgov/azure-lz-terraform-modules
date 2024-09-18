variable "firewall_policy_name" {
  description = "(Required) The name which should be used for this Firewall Policy."
  type        = string  
}

variable "location" {
  description = "(Required) The Azure Region where the Firewall Policy should exist."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the Resource Group where the Firewall Policy should exist."
  type        = string  
}

variable "base_policy_id" {
  description = "(Optional) The ID of the base Firewall Policy."
  type        = string
  default     = null
}

variable "dns" {
  description = "(Optional) A dns block as defined below."
  type        = object({
    proxy_enabled = optional(bool)
    servers = optional(list(string))
  })
  default = null
}

variable "identity" {
  description = "(Optional) An identity block as defined below."
  type = object({
    type = string
    identity_ids = optional(list(string))
  })
  default = null

  # validation {
  #   condition = (
  #     var.identity != null &&
  #     contains(["UserAssigned"], var.identity.type)
  #   )
  #   error_message = "Invalid Identity Type. Only valid opiton is UserAssigned."
  # }
}

variable "insights" {
  description = "(Optional) An insights block as defined below."
  type = object({
    enabled = bool
    default_log_analytics_workspace_id = string
    retention_in_days = optional(number)
    log_analytics_workspace = optional(list(object({
      id = string
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
      id = optional(number)
      state = optional(string) # Can only be "Off", "Alert", or "Deny"
    })))
    traffic_bypass = optional(list(object({
      name = string
      protocol = string
      description = optional(string)
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_ports = optional(list(string))
      source_addresses = optional(list(string))
      source_ip_groups = optional(list(string))
    })))
    private_ranges = optional(list(string))
  })
  default = null
}

variable "private_ip_ranges" {
  description = "(Optional) A list of private IP ranges to which traffic will not be SNAT."
  type = list(string)
  default = []  
}

variable "auto_learn_private_ranges_enabled" {
  description = "(Optional) Whether enable auto learn private IP range."
  type = bool
  default = null  
}

variable "sku" {
  description = "(Optional) The SKU Tier of the Firewall Policy."
  type = string
  default = "Standard"

  validation {
    condition = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Invalid SKU Tier. Valid values are Basic, Standard and Premium."
  }
}

variable "threat_intelligence_allowlist" {
  description = "(Optional) A threat_intelligence_allowlist block as defined below."
  type = object({
    fqdns = optional(list(string))
    ip_addresses = optional(list(string))
  })
  default = null  
}

variable "threat_intelligence_mode" {
  description = "(Optional) The operation mode for Threat Intelligence."
  type = string
  default = "Alert"

  validation {
    condition = contains(["Alert", "Deny", "Off"], var.threat_intelligence_mode)
    error_message = "Invalid Threat Intelligence Mode. Valid values are Alert, Deny and Off."
  }
}

variable "tls_certificate" {
  description = "(Optional) A tls_certificate block as defined below."
  type = object({
    key_vault_secret_id = string
    name = string
  })
  default = null  
}

variable "sql_redirect_allowed" {
  description = "(Optional) Whether SQL Redirect traffic filtering is allowed. Enabling this flag requires no rule using ports between 11000-11999."
  type = bool
  default = null
}

variable "explicit_proxy" {
  description = "(Optional) An explicit_proxy block as defined below."
  type = object({
    enabled = optional(bool)
    http_port = optional(number)
    https_port = optional(number)
    enable_pac_file = optional(bool)
    pac_file_port = optional(number)
    pac_file = optional(string)
  })
  default = null  
}