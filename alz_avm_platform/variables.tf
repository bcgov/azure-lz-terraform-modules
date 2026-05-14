variable "architecture_name" {
  type        = string
  description = "ALZ architecture definition name in ./lib."
  default     = "alz_custom"
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
  description = "Management group IDs used by subscription placement and AMBA platform-branch targeting. When changing IDs, provide a matching custom architecture definition in ./lib and set architecture_name accordingly."
  default     = {}
}

variable "parent_resource_id" {
  type        = string
  description = "Parent management group name. Leave empty to target tenant root group."
  default     = ""

  validation {
    condition     = var.parent_resource_id == "" || !strcontains(var.parent_resource_id, "/")
    error_message = "parent_resource_id must be a management group name (no slashes)."
  }
}

variable "primary_location" {
  type        = string
  description = "Primary Azure region for platform resources."
}

variable "subscription_ids" {
  type = object({
    management   = string
    connectivity = string
    identity     = string
    security     = string
  })
  description = "Dedicated platform subscription IDs (management, connectivity, identity, security)."
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "management_resource_group_name" {
  type        = string
  description = "Resource group for ALZ management resources."
  default     = "rg-alz-management"
}

variable "management_automation_account_name" {
  type        = string
  description = "Automation account name for ALZ management resources."
  default     = "aa-alz-management"
}

variable "management_log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics workspace name for ALZ management resources."
  default     = "law-alz-management"
}

variable "virtual_wan_settings" {
  type        = any
  description = "Virtual WAN shared settings passed to AVM connectivity virtual-wan module."
  default     = {}
}

variable "enable_express_route" {
  type        = bool
  description = "Enable Virtual WAN ExpressRoute gateway creation on all configured hubs."
  default     = false
}

variable "enable_s2s_vpn" {
  type        = bool
  description = "Enable Virtual WAN S2S VPN gateway creation on all configured hubs."
  default     = false
}

variable "external_base_firewall_policy_id" {
  type        = string
  description = "Optional externally managed base firewall policy resource ID to enforce inheritance from platform child policies."
  default     = null
}

variable "express_route_circuit_connections_by_hub" {
  type        = map(any)
  description = "Optional ExpressRoute circuit connections keyed by hub key, then by connection key. Passed to virtual_hubs[*].express_route_circuit_connections."
  default     = {}
}

variable "vpn_sites_by_hub" {
  type        = map(any)
  description = "Optional S2S VPN sites keyed by hub key, then by site key. Passed to virtual_hubs[*].vpn_sites."
  default     = {}
}

variable "vpn_site_connections_by_hub" {
  type        = map(any)
  description = "Optional S2S VPN site connections keyed by hub key, then by connection key. Passed to virtual_hubs[*].vpn_site_connections."
  default     = {}
}

variable "routing_intents_by_hub" {
  type        = map(any)
  description = "Optional routing intents keyed by hub key, then by intent key. Passed to virtual_hubs[*].routing_intents."
  default     = {}
}

variable "private_dns_zones_by_hub" {
  type        = map(any)
  description = "Optional private DNS zone settings keyed by hub key. Merged into virtual_hubs[*].private_dns_zones to support custom zones."
  default     = {}
}

variable "private_dns_resolver_by_hub" {
  type        = map(any)
  description = "Optional private DNS resolver settings keyed by hub key. Merged into virtual_hubs[*].private_dns_resolver."
  default     = {}
}

variable "private_dns_enable_internet_fallback" {
  type        = bool
  description = "Enable default internet fallback (NxDomainRedirect) for private DNS virtual network links."
  default     = true
}

variable "private_dns_resolver_virtual_network_resource_id_by_hub" {
  type        = map(string)
  description = "Optional resolver VNet resource IDs keyed by hub key. When provided, the resolver VNet is linked by default to private DNS zones for that hub."
  default     = {}
}

variable "enable_centralized_logging" {
  type        = bool
  description = "Enable centralized firewall logging by defaulting virtual hub firewall policy insights to the Management subscription Log Analytics workspace."
  default     = true
}

variable "virtual_hubs" {
  type        = any
  description = "Virtual hub map passed to AVM connectivity virtual-wan module; can include firewall and private DNS config per hub."
  default     = {}
}

variable "policy_default_values" {
  type        = map(string)
  description = "Additional ALZ policy default values in jsonencoded string format."
  default     = {}
}

variable "policy_assignments_to_modify" {
  type        = any
  description = "Optional ALZ policy assignment modifications."
  default     = {}
}

variable "policy_assignments_dependencies" {
  type        = list(any)
  description = "Additional dependencies for ALZ policy assignment creation."
  default     = []
}

variable "management_groups_dependencies" {
  type        = list(any)
  description = "Additional dependencies for ALZ management groups creation."
  default     = []
}

variable "enable_telemetry" {
  type        = bool
  description = "Enable telemetry on AVM modules."
  default     = false
}

variable "create_identity_security_bootstrap_resource_groups" {
  type        = bool
  description = "Create placeholder bootstrap resource groups in identity and security subscriptions."
  default     = true
}

variable "identity_bootstrap_resource_group_name" {
  type        = string
  description = "Identity bootstrap resource group name."
  default     = "rg-alz-identity-bootstrap"
}

variable "security_bootstrap_resource_group_name" {
  type        = string
  description = "Security bootstrap resource group name."
  default     = "rg-alz-security-bootstrap"
}

variable "enable_amba" {
  type        = bool
  description = "Enable AMBA ALZ resource module and seed AMBA policy defaults."
  default     = false
}

variable "amba_resource_group_name" {
  type        = string
  description = "Resource group for AMBA resources in management subscription."
  default     = "rg-amba-monitoring"
}

variable "amba_user_assigned_managed_identity_name" {
  type        = string
  description = "UAMI name for AMBA resources."
  default     = "id-amba-alz"
}

variable "alz_library_ref" {
  type        = string
  description = "Azure Landing Zones library reference version."
  default     = "2026.04.3"
}

variable "amba_library_ref" {
  type        = string
  description = "AMBA library reference version."
  default     = "2025.07.0"
}

variable "custom_alz_library_references" {
  type        = list(any)
  description = "Additional ALZ library references for custom policy definitions/initiatives and assignments."
  default     = []
}
