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

variable "spoke_dns_inbound_address_prefix" {
  type = string
}

variable "spoke_dns_outbound_address_prefix" {
  type = string
}

variable "spoke_dns_forward_to" {
  type = list(string)
}
