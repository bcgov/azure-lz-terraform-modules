variable "primary_location" {
  type    = string
  default = "canadacentral"
}

variable "subscription_ids" {
  type = object({
    management   = string
    connectivity = string
    identity     = string
    security     = string
  })
}

variable "tags" {
  type = map(string)
  default = {
    deployedBy = "alz_avm_platform_example"
  }
}

variable "management_group_names" {
  type = object({
    root         = optional(string, "alz")
    platform     = optional(string, "platform")
    management   = optional(string, "management")
    connectivity = optional(string, "connectivity")
    identity     = optional(string, "identity")
    security     = optional(string, "security")
    landingzones = optional(string, "landingzones")
  })
  default = {}
}

variable "custom_alz_library_references" {
  type    = list(any)
  default = []
}

variable "management_resource_group_name" {
  type    = string
  default = "rg-alz-management"
}

variable "management_automation_account_name" {
  type    = string
  default = "aa-alz-management"
}

variable "management_log_analytics_workspace_name" {
  type    = string
  default = "law-alz-management"
}

variable "enable_amba" {
  type    = bool
  default = false
}

variable "enable_express_route" {
  type    = bool
  default = false
}

variable "enable_s2s_vpn" {
  type    = bool
  default = false
}

variable "external_base_firewall_policy_id" {
  type    = string
  default = null
}

variable "enable_centralized_logging" {
  type    = bool
  default = true
}

variable "virtual_wan_settings" {
  type = any
  default = {
    virtual_wan = {
      name = "vwan-hub-canadacentral-001"
    }
  }
}

variable "virtual_hubs" {
  type = any
  default = {
    canadacentral = {
      location = "canadacentral"
      hub = {
        address_prefix = "10.40.0.0/23"
      }
      firewall = {
        enabled = true
      }
      private_dns_zones = {
        enabled = true
      }
    }
  }
}

variable "express_route_circuit_connections_by_hub" {
  type    = map(any)
  default = {}
}

variable "vpn_sites_by_hub" {
  type    = map(any)
  default = {}
}

variable "vpn_site_connections_by_hub" {
  type    = map(any)
  default = {}
}

variable "routing_intents_by_hub" {
  type    = map(any)
  default = {}
}

variable "private_dns_zones_by_hub" {
  type    = map(any)
  default = {}
}

variable "private_dns_resolver_by_hub" {
  type    = map(any)
  default = {}
}

variable "private_dns_enable_internet_fallback" {
  type    = bool
  default = true
}

variable "private_dns_resolver_virtual_network_resource_id_by_hub" {
  type    = map(string)
  default = {}
}

variable "policy_default_values" {
  type    = map(string)
  default = {}
}
