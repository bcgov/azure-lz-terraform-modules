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

variable "firewall_id" {
  description = "Resource ID of the existing enterprise-routable firewall."
  type        = string
}

variable "firewall_private_ip" {
  description = "Private IP of the existing firewall used as the SNAT boundary."
  type        = string
}

variable "dns_forwarding_ruleset_id" {
  description = "Optional central isolated-expansion forwarding ruleset ID. The expansion VNet keeps Azure-provided DNS."
  type        = string
  default     = null
}
