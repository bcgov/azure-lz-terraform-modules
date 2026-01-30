#------------------------------------------------------------------------------
# Environment Variables
#------------------------------------------------------------------------------

variable "environment" {
  type        = string
  description = "The environment name."
  default     = "prod"
}

variable "location" {
  type        = string
  description = "The Azure region."
  default     = "canadacentral"
}

variable "subscription_id_connectivity" {
  type        = string
  description = "The connectivity subscription ID."
}

variable "subscription_id_management" {
  type        = string
  description = "The management subscription ID."
}

#------------------------------------------------------------------------------
# Networking / IPAM Configuration
#------------------------------------------------------------------------------

variable "use_ipam" {
  type        = bool
  description = "Whether to use IPAM for IP address allocation."
  default     = true
}

variable "network_manager_ipam_pool_id" {
  type        = string
  description = "The IPAM Pool ID for IP allocation. Required when use_ipam is true."
  default     = null
}

variable "vnet_address_space" {
  type        = string
  description = "The VNet address space (e.g., 10.100.0.0/24). Required when use_ipam is false."
  default     = null
}

variable "virtual_hub_id" {
  type        = string
  description = "The resource ID of the Virtual WAN Hub to connect the VNet to."
}

variable "internet_security_enabled" {
  type        = bool
  description = "Whether to route internet traffic through the hub firewall."
  default     = true
}

variable "central_postgresql_dns_zone_id" {
  type        = string
  description = "Resource ID of the central PostgreSQL private DNS zone."
}

variable "central_keyvault_dns_zone_id" {
  type        = string
  description = "Resource ID of the central Key Vault private DNS zone."
  default     = null
}

variable "central_grafana_dns_zone_id" {
  type        = string
  description = "Resource ID of the central Grafana private DNS zone."
  default     = null
}

#------------------------------------------------------------------------------
# Identity Variables
#------------------------------------------------------------------------------

variable "cloud_team_group_id" {
  type        = string
  description = "Object ID of the Cloud Team Entra ID group."
}

variable "noc_team_group_id" {
  type        = string
  description = "Object ID of the NOC Team Entra ID group."
  default     = null
}

variable "service_desk_group_id" {
  type        = string
  description = "Object ID of the Service Desk Entra ID group."
  default     = null
}

variable "terraform_spn_object_id" {
  type        = string
  description = "Object ID of the Terraform Service Principal."
  default     = null
}

#------------------------------------------------------------------------------
# ExpressRoute Variables
#------------------------------------------------------------------------------

variable "expressroute_circuits" {
  type = map(object({
    circuit_name        = string
    resource_group_name = string
    bandwidth_mbps      = number
    location            = string
    provider_name       = optional(string, "Unknown")
  }))
  description = "Map of ExpressRoute circuits to monitor."
}

variable "expressroute_gateways" {
  type = map(object({
    gateway_name        = string
    resource_group_name = string
  }))
  description = "Map of ExpressRoute gateways to monitor."
  default     = {}
}

#------------------------------------------------------------------------------
# Alerting Variables
#------------------------------------------------------------------------------

variable "enable_alerting" {
  type        = bool
  description = "Whether to enable alerting."
  default     = true
}

variable "teams_webhook_url" {
  type        = string
  description = "Microsoft Teams webhook URL."
  sensitive   = true
}

variable "cloud_team_email" {
  type        = string
  description = "Cloud team email address."
}

variable "jira_base_url" {
  type        = string
  description = "Jira base URL."
}

variable "jira_user_email" {
  type        = string
  description = "Jira API user email."
}

variable "jira_api_token" {
  type        = string
  description = "Jira API token."
  sensitive   = true
}

variable "jira_project_key" {
  type        = string
  description = "Jira project key."
}

variable "netbox_admin_email" {
  type        = string
  description = "Netbox admin email."
}

#------------------------------------------------------------------------------
# Tags
#------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply."
  default     = {}
}
