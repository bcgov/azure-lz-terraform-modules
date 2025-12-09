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
