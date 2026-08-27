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

variable "private_nat_subnet_address_prefix" {
  description = "Unused /28 or larger prefix already in the routable spoke for the private NAT NVA."
  type        = string
}

variable "ssh_admin_group_object_id" {
  description = "Existing Entra security group object ID granted Virtual Machine Administrator Login on the NVA."
  type        = string
}

variable "ssh_public_key" {
  description = "Optional OpenSSH public key. Omit to let the module generate a throwaway key for VM create."
  type        = string
  default     = null
}

variable "hub_firewall_dns_servers" {
  description = "Hub firewall DNS proxy IPs. The expansion VNet uses these as custom DNS after SNAT."
  type        = list(string)
}

variable "spoke_route_table_id" {
  description = "Optional existing spoke route table to associate with the NVA subnet when the spoke already uses a custom UDR. Leave null so vWAN routing intent programs the NVA subnet."
  type        = string
  default     = null
}

variable "enterprise_routes" {
  description = "Optional extra prefixes to steer to the NVA. Leave empty to use the default 0.0.0.0/0 egress route."
  type        = list(string)
  default     = []
}
