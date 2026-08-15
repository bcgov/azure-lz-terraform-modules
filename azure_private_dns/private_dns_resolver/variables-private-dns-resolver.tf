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
  description = "(Optional) List of forwarding rules to create. Each rule should have name, domain_name, enabled, and target_dns_servers."
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
}

variable "additional_forwarding_rulesets" {
  description = <<-EOT
    Extra forwarding rulesets attached to the existing outbound endpoint.
    Inbound queries use every ruleset on that outbound. These rulesets are
    never linked to the resolver VNet. Linking them there and forwarding to
    168.63.129.16 would recurse.

    Use this for Azure PaaS names that must be resolved by Azure DNS instead
    of public recursion, for example azuredatabricks.net and
    privatelink.azuredatabricks.net.
  EOT
  type = map(object({
    rules = list(object({
      name        = string
      domain_name = string
      enabled     = optional(bool, true)
      target_dns_servers = list(object({
        ip_address = string
        port       = optional(number, 53)
      }))
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for ruleset in var.additional_forwarding_rulesets : [
        for rule in ruleset.rules : endswith(rule.domain_name, ".")
      ]
    ]))
    error_message = "Each additional forwarding rule domain_name must end with a dot (for example azuredatabricks.net.)."
  }

  validation {
    condition = alltrue([
      for key in keys(var.additional_forwarding_rulesets) : can(regex("^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$", key))
    ])
    error_message = "additional_forwarding_rulesets keys must be valid Azure name fragments (letters, numbers, hyphens)."
  }
}
