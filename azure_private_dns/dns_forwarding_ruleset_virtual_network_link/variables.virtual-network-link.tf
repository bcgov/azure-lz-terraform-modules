variable "link_name" {
  description = "The name of the DNS Forwarding Ruleset Virtual Network Link."
  type        = string
}

variable "dns_forwarding_ruleset_id" {
  description = "The ID of the DNS Forwarding Ruleset to which the virtual network link will be added."
  type        = string
}

# variable "virtual_network_id" {
#   description = "The ID of the Virtual Network to link to the DNS Forwarding Ruleset."
#   type        = string
# }

variable "virtual_network_object" {
  description = "(Required) The Virtual Network object that is linked to the Private DNS Resolver."
  type        = any
}
