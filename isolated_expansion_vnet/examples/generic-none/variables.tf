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

variable "spoke_dns_inbound_address_prefix" {
  description = "Unused /28 or larger prefix in the routable spoke for the DNS resolver inbound subnet."
  type        = string
}

variable "spoke_dns_outbound_address_prefix" {
  description = "Unused /28 or larger prefix in the routable spoke for the DNS resolver outbound subnet."
  type        = string
}

variable "spoke_dns_forward_to" {
  description = "DNS servers the spoke resolver forwards all queries to. Use the hub firewall DNS proxy."
  type        = list(string)
}
