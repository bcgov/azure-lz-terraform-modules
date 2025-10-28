# Core Configuration Variables
variable "architecture_name" {
  type        = string
  description = "Architecture name for the ALZ deployment"
}

variable "parent_resource_id" {
  type        = string
  description = "Parent management group resource ID"
}

variable "location" {
  type        = string
  description = "Azure region for resource deployment"
}

variable "root_id" {
  type        = string
  description = "Root management group ID for the ALZ hierarchy"
  default     = ""
}

variable "root_display_name" {
  type        = string
  description = "Display name for the root management group"
  default     = ""
}

variable "dependencies" {
  type        = map(list(string))
  description = "Dependencies for resource creation order"
  default     = {}
}

variable "policy_assignments_to_modify" {
  type = map(object({
    policy_assignments = map(object({
      enforcement_mode = optional(string, null)
      identity         = optional(string, null)
      identity_ids     = optional(list(string), null)
      parameters       = optional(map(any), null)
    }))
  }))
  description = "Policy assignments to modify"
  default     = {}
}

# Platform Landing Zone Configuration Variables
variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Flag to enable/disable telemetry"
}

variable "starter_locations" {
  type        = list(string)
  description = "The default for Azure resources. (e.g 'uksouth')"
  validation {
    condition     = length(var.starter_locations) > 0
    error_message = "You must provide at least one starter location region."
  }
  validation {
    condition     = var.connectivity_type == "none" || ((length(var.virtual_wan_virtual_hubs) <= length(var.starter_locations)) || (length(var.hub_and_spoke_vnet_virtual_networks) <= length(var.starter_locations)))
    error_message = "The number of regions supplied in `starter_locations` must match the number of regions specified for connectivity."
  }
}

variable "subscription_ids" {
  description = "The list of subscription IDs to deploy the Platform Landing Zones into"
  type        = map(string)
  default     = {}
  nullable    = false
  validation {
    condition     = length(var.subscription_ids) == 0 || alltrue([for id in values(var.subscription_ids) : can(regex("^([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$", id))])
    error_message = "All subscription IDs must be valid GUIDs"
  }
  validation {
    condition     = length(var.subscription_ids) == 0 || alltrue([for id in keys(var.subscription_ids) : contains(["management", "connectivity", "identity", "security"], id)])
    error_message = "The keys of the subscription_ids map must be one of 'management', 'connectivity', 'identity' or 'security'"
  }
}

variable "subscription_id_connectivity" {
  description = "DEPRECATED (use subscription_ids instead): The identifier of the Connectivity Subscription"
  type        = string
  default     = null
  validation {
    condition     = var.subscription_id_connectivity == null || can(regex("^([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$", var.subscription_id_connectivity))
    error_message = "The subscription ID must be a valid GUID"
  }
}

variable "subscription_id_identity" {
  description = "DEPRECATED (use subscription_ids instead): The identifier of the Identity Subscription"
  type        = string
  default     = null
  validation {
    condition     = var.subscription_id_identity == null || can(regex("^([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$", var.subscription_id_identity))
    error_message = "The subscription ID must be a valid GUID"
  }
}

variable "subscription_id_management" {
  description = "DEPRECATED (use subscription_ids instead): The identifier of the Management Subscription"
  type        = string
  default     = null
  validation {
    condition     = var.subscription_id_management == null || can(regex("^([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})$", var.subscription_id_management))
    error_message = "The subscription ID must be a valid GUID"
  }
}

variable "root_parent_management_group_id" {
  type        = string
  default     = ""
  description = "This is the id of the management group that the ALZ hierarchy will be nested under, will default to the Tenant Root Group"
}

variable "custom_replacements" {
  type = object({
    names                      = optional(map(string), {})
    resource_group_identifiers = optional(map(string), {})
    resource_identifiers       = optional(map(string), {})
  })
  default = {
    names                      = {}
    resource_group_identifiers = {}
    resource_identifiers       = {}
  }
  description = "Custom replacements"
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

# Connectivity Configuration
variable "connectivity_type" {
  type        = string
  description = "The type of network connectivity technology to use for the private DNS zones"
  default     = "hub_and_spoke_vnet"
  validation {
    condition     = contains(["hub_and_spoke_vnet", "virtual_wan", "none"], var.connectivity_type)
    error_message = "The connectivity type must be either 'hub_and_spoke_vnet', 'virtual_wan' or 'none'"
  }
}

variable "connectivity_resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string))
    settings = optional(any)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of resource groups to create. These must be created before the connectivity module is applied.

The following attributes are supported:

  - name: The name of the resource group
  - location: The location of the resource group
  - settings: (Optional) An object, which can include an `enabled` setting value that indicates whether the resource group should be created.

DESCRIPTION
}

variable "hub_and_spoke_vnet_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The shared settings for the hub and spoke networks. This is where global resources are defined.

The following attributes are supported:

  - ddos_protection_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan

DESCRIPTION
}

variable "hub_and_spoke_vnet_virtual_networks" {
  type = map(object({
    hub_virtual_network = any
    virtual_network_gateways = optional(object({
      subnet_address_prefix                     = string
      subnet_default_outbound_access_enabled    = optional(bool, false)
      route_table_creation_enabled              = optional(bool, false)
      route_table_name                          = optional(string)
      route_table_bgp_route_propagation_enabled = optional(bool, false)
      express_route                             = optional(any)
      vpn                                       = optional(any)
    }))
    private_dns_zones    = optional(any)
    private_dns_resolver = optional(any)
    bastion              = optional(any)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of hub networks to create.

The following attributes are supported:

  - hub_virtual_network: The hub virtual network settings. Detailed information about the hub virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-hubnetworking
  - virtual_network_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-vnetgateway
  - private_dns_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones
  - private_dns_resolver: (Optional) The private DNS resolver settings. Detailed information about the private DNS resolver can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver/
  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/

DESCRIPTION
}

variable "virtual_wan_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The shared settings for the Virtual WAN. This is where global resources are defined.

The following attributes are supported:

  - ddos_protection_plan: (Optional) The DDoS protection plan settings. Detailed information about the DDoS protection plan can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-ddosprotectionplan

The Virtual WAN module attributes are also supported. Detailed information about the Virtual WAN module variables can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan

DESCRIPTION
}

variable "virtual_wan_virtual_hubs" {
  type = map(object({
    hub                  = any
    firewall             = optional(any)
    firewall_policy      = optional(any)
    private_dns_zones    = optional(any)
    private_dns_resolver = optional(any)
    bastion              = optional(any)
    virtual_network_gateways = optional(object({
      express_route = optional(any)
      vpn           = optional(any)
    }))
    side_car_virtual_network = optional(any)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of virtual hubs to create.

The following attributes are supported:

  - hub: The virtual hub settings. Detailed information about the virtual hub can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan
  - firewall: (Optional) The firewall settings. Detailed information about the firewall can be found in the Virtual WAN module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan
  - firewall_policy: (Optional) The firewall policy settings. Detailed information about the firewall policy can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-firewall-policy
  - private_dns_zones: (Optional) The private DNS zone settings. Detailed information about the private DNS zone can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-ptn-network-private-link-private-dns-zones
  - private_dns_resolver: (Optional) The private DNS resolver settings. Detailed information about the private DNS resolver can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver/
  - bastion: (Optional) The bastion host settings. Detailed information about the bastion can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/
  - virtual_network_gateways: (Optional) The virtual network gateway settings. Detailed information about the virtual network gateway can be found in the Virtual WAN module's README: https://registry.terraform.io/modules/Azure/avm-ptn-virtualwan
  - side_car_virtual_network: (Optional) The side car virtual network settings. Detailed information about the side car virtual network can be found in the module's README: https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork

DESCRIPTION
}

# Management Configuration
variable "management_resource_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management resources. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz-management
DESCRIPTION
}

variable "management_group_settings" {
  type        = any
  default     = {}
  description = <<DESCRIPTION
The settings for the management groups. Details of the settings can be found in the module documentation at https://registry.terraform.io/modules/Azure/avm-ptn-alz
DESCRIPTION
}
