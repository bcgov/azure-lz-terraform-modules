variable "name" {
  description = "Logical name for the isolated expansion VNet. Used as the Virtual Network name unless virtual_network_name is set. In this landing zone, the VNet name should end with `-isolated-expansion` so platform policy can distinguish it from enterprise-routed spokes."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 55 && can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9_]$", var.name))
    error_message = "name must be 2-55 characters so peering names prefixed with isolated-expansion- remain within Azure's 80-character limit. Use letters, numbers, underscores, periods, or hyphens."
  }
}

variable "virtual_network_name" {
  description = "Override the Azure Virtual Network name. Defaults to `name`. Prefer a name ending in `-isolated-expansion`."
  type        = string
  default     = null
}

variable "location" {
  description = "(Required) Azure region to deploy to. Changing this forces a new resource to be created."
  type        = string

  validation {
    condition     = contains(["canada central", "canadacentral", "canada east", "canadaeast"], lower(var.location))
    error_message = "ERROR: Only Canadian Azure Regions are allowed! Valid values for the variable \"location\" are: \"canadaeast\",\"canadacentral\"."
  }
}

variable "resource_group_name" {
  description = "(Required) Name of the existing resource group that will contain the expansion VNet and its supporting resources."
  type        = string
}

variable "address_space" {
  description = "Isolated RFC1918 address space for the expansion VNet. Must not overlap the routable workload VNet, other directly peered networks, or destinations the expansion workload must reach without SNAT. This prefix must never be advertised into the enterprise routing domain. Defaults to 10.10.0.0/16."
  type        = list(string)
  default     = ["10.10.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR prefix."
  }

  validation {
    condition = alltrue([
      for cidr in var.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "Each address_space value must be a valid CIDR prefix."
  }

  validation {
    condition = alltrue([
      for cidr in var.address_space : (
        (startswith(cidrhost(cidr, 0), "10.") && tonumber(split("/", cidr)[1]) >= 8) ||
        (can(regex("^172\\.(1[6-9]|2[0-9]|3[01])\\.", cidrhost(cidr, 0))) && tonumber(split("/", cidr)[1]) >= 12) ||
        (startswith(cidrhost(cidr, 0), "192.168.") && tonumber(split("/", cidr)[1]) >= 16)
      )
    ])
    error_message = "Each address_space prefix must be fully contained in RFC1918 space (10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16)."
  }
}

variable "routable_vnet" {
  description = "The existing enterprise-routed workload VNet that this expansion VNet will be directly peered to. This is the only intended private path out of the isolated address space besides an optional firewall SNAT boundary."
  type = object({
    id                  = string
    name                = string
    resource_group_name = string
    address_space       = optional(list(string), [])
  })

  validation {
    condition     = length(var.routable_vnet.id) > 0 && length(var.routable_vnet.name) > 0 && length(var.routable_vnet.resource_group_name) > 0
    error_message = "routable_vnet.id, routable_vnet.name, and routable_vnet.resource_group_name are required."
  }

  validation {
    condition = alltrue([
      for cidr in var.routable_vnet.address_space : can(cidrhost(cidr, 0))
    ])
    error_message = "Each routable_vnet.address_space value must be a valid CIDR prefix."
  }
}

variable "subnets" {
  description = "Optional subnet map for the expansion VNet. Leave empty when the caller creates workload subnets separately. Wrapper modules should add service-specific delegation, endpoints, and NSG rules here rather than changing the core pattern."
  type = map(object({
    address_prefix                                = string
    name                                          = optional(string)
    nsg_name                                      = optional(string)
    create_nsg                                    = optional(bool, true)
    nsg_id                                        = optional(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    default_outbound_access_enabled               = optional(bool, false)
    associate_nat_gateway                         = optional(bool, true)
    associate_route_table                         = optional(bool, true)
    delegation = optional(object({
      name         = optional(string)
      service_name = string
      actions      = optional(list(string), ["Microsoft.Network/virtualNetworks/subnets/join/action"])
    }))
    nsg_rules = optional(map(object({
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      description                  = optional(string)
      source_port_range            = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_range       = optional(string)
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for s in var.subnets : can(cidrhost(s.address_prefix, 0))
    ])
    error_message = "Each subnet address_prefix must be a valid CIDR prefix."
  }

  validation {
    condition = alltrue([
      for s in var.subnets : contains(["Enabled", "Disabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], s.private_endpoint_network_policies)
    ])
    error_message = "private_endpoint_network_policies must be Enabled, Disabled, NetworkSecurityGroupEnabled, or RouteTableEnabled."
  }
}

variable "egress" {
  description = "Outbound connectivity model. Defaults to `none` (private paths only: local VNet, direct peering, and Private Endpoints, with no NAT Gateway or Internet route). Use `nat` when the workload also needs public egress. Use `firewall_snat` when the workload must reach enterprise destinations beyond the peer, with the isolated prefix translated before it enters the enterprise routing domain."
  type = object({
    mode = optional(string, "none")
    nat = optional(object({
      public_ip_count = optional(number, 1)
      idle_timeout    = optional(number, 10)
      zones           = optional(list(string), ["1"])
      sku_name        = optional(string, "Standard")
      }), {
      public_ip_count = 1
      idle_timeout    = 10
      zones           = ["1"]
      sku_name        = "Standard"
    })
    firewall = optional(object({
      deployment_mode                 = optional(string, "existing")
      firewall_id                     = optional(string)
      firewall_private_ip             = optional(string)
      direct_peer_bypass              = optional(bool, true)
      route_internet_through_firewall = optional(bool, true)
    }))
  })
  default = {
    mode = "none"
  }

  validation {
    condition     = contains(["nat", "firewall_snat", "none"], var.egress.mode)
    error_message = "egress.mode must be nat, firewall_snat, or none."
  }

  validation {
    condition = var.egress.mode != "firewall_snat" || (
      var.egress.firewall != null &&
      try(var.egress.firewall.firewall_id, null) != null &&
      try(var.egress.firewall.firewall_private_ip, null) != null
    )
    error_message = "Firewall configuration (firewall_id and firewall_private_ip) is required when using firewall_snat."
  }

  validation {
    condition     = var.egress.mode != "firewall_snat" || try(var.egress.firewall.deployment_mode, "existing") == "existing"
    error_message = "Only an existing firewall is supported. egress.firewall.deployment_mode must be \"existing\"."
  }

  validation {
    condition     = var.egress.mode != "nat" || (var.egress.nat.public_ip_count >= 1 && var.egress.nat.public_ip_count <= 16)
    error_message = "egress.nat.public_ip_count must be between 1 and 16."
  }

  validation {
    condition     = var.egress.mode != "nat" || (var.egress.nat.idle_timeout >= 4 && var.egress.nat.idle_timeout <= 120)
    error_message = "egress.nat.idle_timeout must be between 4 and 120 minutes."
  }

  validation {
    condition     = var.egress.mode != "nat" || contains(["Standard", "StandardV2"], var.egress.nat.sku_name)
    error_message = "egress.nat.sku_name must be Standard or StandardV2."
  }
}

variable "enterprise_routes" {
  description = "Enterprise prefixes that firewall_snat mode should send to the firewall. Never hard-code these in a wrapper; the caller supplies the prefixes that must be translated before they enter the enterprise routing domain."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.enterprise_routes : can(cidrhost(cidr, 0))
    ])
    error_message = "Each enterprise_routes value must be a valid CIDR prefix."
  }
}

variable "disallowed_address_spaces" {
  description = "Known directly connected or otherwise incompatible CIDRs. The module fails if the expansion address space overlaps any of these prefixes. Full enterprise IPAM validation remains outside Terraform."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.disallowed_address_spaces : can(cidrhost(cidr, 0))
    ])
    error_message = "Each disallowed_address_spaces value must be a valid CIDR prefix."
  }
}

variable "dns" {
  description = "DNS configuration for the expansion VNet. Azure-provided DNS is the default. Use custom servers only when those resolvers are reachable from the expansion VNet (in the directly peered workload VNet for NAT mode, or via firewall SNAT for enterprise DNS)."
  type = object({
    mode    = optional(string, "azure")
    servers = optional(list(string), [])
  })
  default = {
    mode = "azure"
  }

  validation {
    condition     = contains(["azure", "custom"], var.dns.mode)
    error_message = "dns.mode must be azure or custom."
  }

  validation {
    condition     = var.dns.mode != "custom" || length(var.dns.servers) > 0
    error_message = "dns.servers is required when dns.mode is custom."
  }
}

variable "private_dns_zone_ids" {
  description = "Existing private DNS zone resource IDs to link to the expansion VNet. Central zones should be reused rather than duplicated. The identity applying this module must be able to write virtual network links on those zones."
  type        = list(string)
  default     = []
}

variable "link_private_dns_to_routable_vnet" {
  description = "Also create private DNS zone links on the routable workload VNet. Leave false when those zones are already linked centrally."
  type        = bool
  default     = false
}

variable "nsg_rules" {
  description = "Additional NSG rules applied to every subnet NSG created by this module. Use subnet-level nsg_rules for workload-specific exceptions. Do not add allow-all rules from the expansion CIDR."
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    description                  = optional(string)
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = {}
}

variable "nsg_default_rules_enabled" {
  description = "Create the module's baseline NSG rules (Azure Load Balancer inbound, VNet outbound, deny Internet inbound, Internet outbound in nat/firewall_snat, Internet deny in none, and enterprise-route outbound in firewall mode). Disable only when supplying a complete custom rule set."
  type        = bool
  default     = true
}

variable "tags" {
  description = "(Optional) Additional tags to merge with the isolated_expansion classification tags."
  type        = map(string)
  default     = {}
}
