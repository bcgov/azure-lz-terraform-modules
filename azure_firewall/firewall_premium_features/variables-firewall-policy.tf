variable "firewall_policy_name" {
  description = "The name of the Azure Firewall Policy."
  type        = string
}

variable "firewall_policy_resource_group_name" {
  description = "The name of the resource group in which the Azure Firewall Policy exists."
  type        = string
}

variable "idps_private_ip_ranges" {
  description = "(Optional) A list of Private IP address ranges to identify traffic direction. By default, only ranges defined by IANA RFC 1918 are considered private IP addresses."
  type        = list(string)
  default = []
}