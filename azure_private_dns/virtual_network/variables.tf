variable "environment" {
  description = "(Required) This is either LIVE or FORGE."
  type        = string

  validation {
    condition     = contains(["LIVE", "FORGE"], var.environment)
    error_message = "ERROR: Only LIVE or FORGE are allowed for the variable \"environment\"."
  }
}

variable "subscription_id_connectivity" {
  description = "(Required) Subscription ID to use for \"connectivity\" resources."
  type        = string
}

variable "location" {
  description = "(Required) Azure region to deploy to. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["Canada Central", "canadacentral", "Canada East", "canadaeast"], var.location)
    error_message = "ERROR: Only Canadian Azure Regions are allowed! Valid values for the variable \"location\" are: \"canadaeast\",\"canadacentral\"."
  }
}

variable "primary_location" {
  description = "Primary Azure region short name for Network Watcher and traffic analytics resources. Must align with location."
  type        = string
  default     = "canadacentral"

  validation {
    condition     = contains(["canadacentral", "canadaeast"], var.primary_location)
    error_message = "ERROR: Valid values for primary_location are: \"canadaeast\", \"canadacentral\"."
  }

  validation {
    condition     = var.primary_location == replace(lower(var.location), " ", "")
    error_message = "ERROR: primary_location must match location using the Azure region short name without spaces."
  }
}

variable "secondary_location" {
  description = "Secondary Azure region short name reserved for future region expansion."
  type        = string
  default     = "canadaeast"

  validation {
    condition     = contains(["canadacentral", "canadaeast"], var.secondary_location)
    error_message = "ERROR: Valid values for secondary_location are: \"canadaeast\", \"canadacentral\"."
  }
}

variable "private_dns_resource_group_name" {
  description = "(Required) Name of the Resource Group to deploy the Private DNS Resolver into."
  type        = string
}

variable "virtual_wan_hub_name" {
  description = "(Required) Name of the Virtual WAN Hub to connect to."
  type        = string
}

variable "virtual_wan_hub_resource_group" {
  description = "(Required) Resource Group of the Virtual WAN hub."
  type        = string
}

variable "firewall_private_ip_address" {
  description = "(Required) Private IP address of the Azure Firewall to connect to."
  type        = list(string)
}

variable "private_dns_resolver_virtual_network_name" {
  description = "(Required) Name of the Virtual Network to deploy the Private DNS Resolver into."
  type        = string
}

variable "network_manager_ipam_pool_id" {
  type        = string
  description = "IPAM Pool id"
}


variable "vnet_flow_logs_storage_account_id" {
  description = "Storage account ID for storing VNet flow logs"
  type        = string
}

variable "workspace_id" {
  description = "Log Analytics workspace ID for traffic analytics"
  type        = string
}

variable "workspace_resource_id" {
  description = "Log Analytics workspace resource ID for traffic analytics"
  type        = string
}
