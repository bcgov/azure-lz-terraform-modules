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

variable "firewall_subnet_address_prefix" {
  description = "Unused /26 or larger prefix already in the routable spoke for AzureFirewallSubnet."
  type        = string
}

variable "firewall_management_subnet_address_prefix" {
  description = "Unused /26 or larger prefix already in the routable spoke for AzureFirewallManagementSubnet."
  type        = string
}

variable "hub_firewall_dns_servers" {
  description = "Hub firewall DNS proxy IPs. The expansion VNet uses these as custom DNS after SNAT."
  type        = list(string)
}

variable "spoke_route_table_id" {
  description = "Optional existing spoke route table to associate with AzureFirewallSubnet when the spoke already uses a custom UDR. Leave null so vWAN routing intent programs the data subnet."
  type        = string
  default     = null
}

variable "dns_forwarding_ruleset_id" {
  description = "Optional central isolated-expansion forwarding ruleset ID. The expansion VNet keeps Azure-provided DNS."
  type        = string
  default     = null
}
