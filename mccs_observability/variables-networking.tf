#------------------------------------------------------------------------------
# Networking Variables
#------------------------------------------------------------------------------

variable "vnet_name" {
  type        = string
  description = "Override for the VNet name. If not provided, a name will be generated."
  default     = null
}

#------------------------------------------------------------------------------
# IPAM Configuration
#------------------------------------------------------------------------------

variable "use_ipam" {
  type        = bool
  description = "Whether to use Azure Network Manager IPAM for IP address allocation. If true, network_manager_ipam_pool_id is required. If false, vnet_address_space is required."
  default     = true
}

variable "network_manager_ipam_pool_id" {
  type        = string
  description = "The resource ID of the Azure Network Manager IPAM Pool for IP address allocation. Required when use_ipam is true."
  default     = null

  validation {
    condition     = var.network_manager_ipam_pool_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/networkManagers/.+/ipamPools/.+$", var.network_manager_ipam_pool_id))
    error_message = "network_manager_ipam_pool_id must be a valid IPAM Pool resource ID."
  }
}

#------------------------------------------------------------------------------
# Static Address Space (used when use_ipam is false)
#------------------------------------------------------------------------------

variable "vnet_address_space" {
  type        = string
  description = "The address space for the VNet (e.g., 10.100.0.0/24). Required when use_ipam is false. Will be split into /26 subnets."
  default     = null

  validation {
    condition     = var.vnet_address_space == null || can(cidrhost(var.vnet_address_space, 0))
    error_message = "vnet_address_space must be a valid CIDR block."
  }
}

#------------------------------------------------------------------------------
# Virtual WAN Hub Connection
#------------------------------------------------------------------------------

variable "virtual_hub_id" {
  type        = string
  description = "The resource ID of the Virtual WAN Hub to connect the VNet to."
}

variable "internet_security_enabled" {
  type        = bool
  description = "Whether to enable internet security (route internet traffic through the hub firewall)."
  default     = true
}

#------------------------------------------------------------------------------
# Private DNS Zone Variables
#------------------------------------------------------------------------------

variable "central_postgresql_dns_zone_id" {
  type        = string
  description = "The resource ID of the central Private DNS Zone for PostgreSQL (privatelink.postgres.database.azure.com)."
}

variable "central_keyvault_dns_zone_id" {
  type        = string
  description = "The resource ID of the central Private DNS Zone for Key Vault (privatelink.vaultcore.azure.net)."
  default     = null
}

variable "central_grafana_dns_zone_id" {
  type        = string
  description = "The resource ID of the central Private DNS Zone for Grafana (privatelink.grafana.azure.com)."
  default     = null
}

variable "create_private_dns_zone_groups" {
  type        = bool
  description = "Whether to create private DNS zone groups for private endpoints. Set to false if using DINE policies."
  default     = false
}

#------------------------------------------------------------------------------
# Network Access Control
#------------------------------------------------------------------------------

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "List of IP addresses or CIDR ranges allowed to access Key Vault and Storage Accounts through public endpoints. Used for Terraform runners or admin access."
  default     = []

  validation {
    condition = alltrue([
      for ip in var.allowed_ip_addresses : can(cidrhost("${ip}/32", 0)) || can(cidrhost(ip, 0))
    ])
    error_message = "Each entry must be a valid IP address or CIDR range."
  }
}
