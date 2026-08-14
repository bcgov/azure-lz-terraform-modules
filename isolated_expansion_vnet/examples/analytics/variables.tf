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

variable "private_dns_zone_ids" {
  type    = list(string)
  default = []
}
