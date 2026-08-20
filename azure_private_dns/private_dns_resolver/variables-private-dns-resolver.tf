variable "private_dns_resolver_name" {
  description = "(Required) Specifies the name which should be used for this Private DNS Resolver."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the Resource Group where the Private DNS Resolver should exist."
  type        = string
}

variable "virtual_network_object" {
  description = "(Required) The Virtual Network object that is linked to the Private DNS Resolver."
  type        = any
}

variable "forwarding_rules" {
  description = "(Optional) On-prem / conditional forwarding rules for the existing ruleset. Do not add a '.' catch-all here. Isolated expansion VNets use isolated_expansion_forwarding_ruleset."
  type = list(object({
    name        = string
    domain_name = string
    enabled     = bool
    target_dns_servers = list(object({
      ip_address = string
      port       = number
    }))
  }))
  default = []

  validation {
    condition     = !contains([for rule in var.forwarding_rules : rule.domain_name], ".")
    error_message = "Do not put a '.' catch-all on the on-prem forwarding ruleset. Isolated expansion uses the dedicated isolated_expansion_forwarding_ruleset."
  }
}

variable "isolated_expansion_forwarding_ruleset" {
  description = "Second forwarding ruleset on the existing outbound for *-isolated-expansion VNets. One rule: '.' → this resolver's inbound. This module does not create VNet links. Expansion modules pass the output ID as dns_forwarding_ruleset_id. Do not link this ruleset to the resolver VNet or to *-vwan-spoke VNets."
  type = object({
    enabled = optional(bool, true)
    name    = optional(string)
  })
  default = {
    enabled = true
  }

  validation {
    condition     = var.isolated_expansion_forwarding_ruleset.name == null || can(regex("(?i)isolated-expansion", var.isolated_expansion_forwarding_ruleset.name))
    error_message = "isolated_expansion_forwarding_ruleset.name must contain 'isolated-expansion' so it is not mistaken for the on-prem ruleset or linked to *-vwan-spoke VNets."
  }
}
