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

variable "ssh_public_key" {
  description = "OpenSSH public key for the private NAT NVA. The VM has no public IP."
  type        = string
}

variable "spoke_route_table_id" {
  description = "Optional existing spoke route table to associate with the NVA subnet so SNATed packets follow the spoke egress path."
  type        = string
  default     = null
}

variable "enterprise_routes" {
  description = "Enterprise prefixes the expansion VNet should send to the spoke NVA."
  type        = list(string)
  default = [
    "10.0.0.0/8",
    "142.0.0.0/8"
  ]
}
