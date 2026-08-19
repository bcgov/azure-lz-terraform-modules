variable "location" {
  type    = string
  default = "canadacentral"
}

variable "resource_group_name" {
  type = string
}

variable "routable_vnet_id" {
  type = string
}

variable "routable_vnet_name" {
  type = string
}

variable "routable_vnet_resource_group_name" {
  type = string
}

variable "routable_vnet_address_space" {
  type = list(string)
}

variable "spoke_dns_resolver" {
  description = "Optional spoke DNS Private Resolver. Off by default."
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
