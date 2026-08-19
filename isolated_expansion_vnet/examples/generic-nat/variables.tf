variable "subscription_id" {
  description = "Subscription that contains the workload resource group. Use a placeholder in committed tfvars."
  type        = string
}

variable "location" {
  description = "Azure region for the expansion VNet."
  type        = string
  default     = "canadacentral"
}

variable "resource_group_name" {
  description = "Existing network resource group name."
  type        = string
}

variable "routable_vnet_id" {
  description = "Resource ID of the enterprise-routed workload VNet."
  type        = string
}

variable "routable_vnet_name" {
  description = "Name of the enterprise-routed workload VNet."
  type        = string
}

variable "routable_vnet_resource_group_name" {
  description = "Resource group of the enterprise-routed workload VNet."
  type        = string
}

variable "routable_vnet_address_space" {
  description = "Address space of the enterprise-routed workload VNet."
  type        = list(string)
}

variable "dns_forwarding_ruleset_id" {
  description = "Optional central isolated-expansion forwarding ruleset ID. The expansion VNet keeps Azure-provided DNS."
  type        = string
  default     = null
}

variable "spoke_dns_resolver" {
  description = "Optional spoke DNS Private Resolver. Off by default. Mutually exclusive with dns_forwarding_ruleset_id."
  type = object({
    enabled                    = optional(bool, false)
    inbound_address_prefix     = optional(string)
    outbound_address_prefix    = optional(string)
    forward_to                 = optional(list(string), [])
    additional_forward_domains = optional(list(string), [])
  })
  default = {
    enabled = false
  }
}
