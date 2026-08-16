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
  description = "The existing enterprise-routed workload VNet that this expansion VNet will be directly peered to. This is the only intended private path out of the isolated address space besides an optional spoke firewall or private-NAT SNAT hop. address_space is required for firewall_snat and private_nat so those spoke subnets can be validated against the spoke."
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
  description = "Optional subnet map for the expansion VNet. Leave empty when the caller creates workload subnets separately. Wrapper modules should add service-specific delegation, endpoints, and NSG rules here rather than changing the core pattern. associate_route_table attaches the active egress route table through a dedicated association resource."
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
  description = "Outbound connectivity model. Defaults to `none` (private paths only: local VNet, direct peering, and Private Endpoints, with no NAT Gateway or Internet route). Use `nat` when the workload also needs public egress. Use `firewall_snat` to create a forced-tunnel Azure Firewall in the routable spoke that SNATs isolated sources to the firewall's spoke IP. Use `private_nat` to create a Linux NVA in the spoke for the same translation contract."
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
      subnet_address_prefix            = string
      management_subnet_address_prefix = string
      private_ip                       = optional(string)
      sku_tier                         = optional(string, "Standard")
      spoke_route_table_id             = optional(string)
      direct_peer_bypass               = optional(bool, true)
      route_internet_through_firewall  = optional(bool, true)
      zones                            = optional(list(string))
    }))
    private_nat = optional(object({
      subnet_address_prefix      = string
      ssh_public_key             = string
      subnet_name                = optional(string)
      private_ip                 = optional(string)
      vm_size                    = optional(string, "Standard_B2s")
      admin_username             = optional(string, "azureadmin")
      os_disk_size_gb            = optional(number, 30)
      zone                       = optional(string)
      spoke_route_table_id       = optional(string)
      ssh_source_prefixes        = optional(list(string), [])
      direct_peer_bypass         = optional(bool, true)
      route_internet_through_nva = optional(bool, true)
      image = optional(object({
        publisher = optional(string, "Canonical")
        offer     = optional(string, "ubuntu-26_04-lts")
        sku       = optional(string, "server-gen1")
        version   = optional(string, "latest")
      }), {})
    }))
  })
  default = {
    mode = "none"
  }

  validation {
    condition     = contains(["nat", "firewall_snat", "private_nat", "none"], var.egress.mode)
    error_message = "egress.mode must be nat, firewall_snat, private_nat, or none."
  }

  validation {
    condition = var.egress.mode != "firewall_snat" || (
      var.egress.firewall != null &&
      try(var.egress.firewall.subnet_address_prefix, null) != null &&
      can(cidrhost(var.egress.firewall.subnet_address_prefix, 0)) &&
      try(var.egress.firewall.management_subnet_address_prefix, null) != null &&
      can(cidrhost(var.egress.firewall.management_subnet_address_prefix, 0))
    )
    error_message = "egress.firewall.subnet_address_prefix and management_subnet_address_prefix are required CIDRs when using firewall_snat."
  }

  validation {
    condition = var.egress.mode != "firewall_snat" || try(var.egress.firewall, null) == null || (
      tonumber(split("/", var.egress.firewall.subnet_address_prefix)[1]) <= 26 &&
      tonumber(split("/", var.egress.firewall.management_subnet_address_prefix)[1]) <= 26
    )
    error_message = "Azure Firewall subnets must be /26 or larger (prefix length 26 or smaller)."
  }

  validation {
    condition     = var.egress.mode != "firewall_snat" || try(var.egress.firewall.sku_tier, "Standard") == null || contains(["Standard", "Premium"], var.egress.firewall.sku_tier)
    error_message = "egress.firewall.sku_tier must be Standard or Premium."
  }

  validation {
    condition = var.egress.mode != "private_nat" || (
      var.egress.private_nat != null &&
      try(var.egress.private_nat.subnet_address_prefix, null) != null &&
      can(cidrhost(var.egress.private_nat.subnet_address_prefix, 0)) &&
      try(var.egress.private_nat.ssh_public_key, null) != null &&
      length(try(var.egress.private_nat.ssh_public_key, "")) > 0
    )
    error_message = "egress.private_nat.subnet_address_prefix and ssh_public_key are required when using private_nat."
  }

  validation {
    condition = var.egress.mode != "private_nat" || try(var.egress.private_nat, null) == null || (
      tonumber(split("/", var.egress.private_nat.subnet_address_prefix)[1]) <= 28
    )
    error_message = "egress.private_nat.subnet_address_prefix must be /28 or larger (prefix length 28 or smaller)."
  }

  validation {
    condition     = var.egress.mode != "private_nat" || try(var.egress.private_nat.ssh_public_key, null) == null || can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ", var.egress.private_nat.ssh_public_key))
    error_message = "egress.private_nat.ssh_public_key must be an OpenSSH public key (ssh-rsa, ssh-ed25519, or ecdsa-sha2-nistp*)."
  }

  validation {
    condition = var.egress.mode != "private_nat" || try(var.egress.private_nat.admin_username, "azureadmin") == null || !contains([
      "admin", "administrator", "root", "user", "guest"
    ], lower(var.egress.private_nat.admin_username))
    error_message = "egress.private_nat.admin_username cannot be a reserved Azure account name."
  }

  validation {
    condition     = var.egress.mode != "private_nat" || try(var.egress.private_nat.os_disk_size_gb, 30) >= 30
    error_message = "egress.private_nat.os_disk_size_gb must be at least 30."
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
  description = "Optional extra prefixes to steer to the SNAT hop. The default egress path is 0.0.0.0/0 (route_internet_through_nva / route_internet_through_firewall). Use this only when that default is disabled and specific prefixes still need translation. Do not list 10.0.0.0/8, 142.0.0.0/8, or other stand-ins for default egress."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.enterprise_routes : can(cidrhost(cidr, 0))
    ])
    error_message = "Each enterprise_routes value must be a valid CIDR prefix."
  }

  validation {
    condition     = !contains(var.enterprise_routes, "0.0.0.0/0")
    error_message = "Do not put 0.0.0.0/0 in enterprise_routes. Use route_internet_through_nva or route_internet_through_firewall."
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
  description = "DNS configuration for the expansion VNet. Azure-provided DNS is the default. Use custom servers only when those resolvers are reachable from the expansion VNet (in the directly peered workload VNet for NAT mode, or via firewall SNAT for enterprise DNS). When spoke_dns_resolver.enabled is true, leave this at the default; the module points the expansion VNet at the spoke inbound endpoint."
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

variable "spoke_dns_resolver" {
  description = "Optional DNS Private Resolver in the routable spoke. When enabled, the expansion VNet uses the spoke inbound endpoint as custom DNS and the resolver forwards all queries to forward_to (typically the hub firewall DNS proxy). additional_forward_domains creates more-specific rules to the same forward_to servers; use it for names such as azuredatabricks.net that must stay on the already-allowed firewall DNS path. Pass routable_vnet.address_space so the inbound NSG allows spoke clients as well as the expansion VNet. Private DNS zone links on the expansion VNet are not required. Enable on at most one expansion module per spoke. inbound_address_prefix and outbound_address_prefix must be unused /28 or larger prefixes already in the spoke address space."
  type = object({
    enabled                    = optional(bool, false)
    inbound_address_prefix     = optional(string)
    outbound_address_prefix    = optional(string)
    inbound_ip                 = optional(string)
    forward_to                 = optional(list(string), [])
    additional_forward_domains = optional(list(string), [])
  })
  default = {
    enabled = false
  }

  validation {
    condition     = !var.spoke_dns_resolver.enabled || (try(var.spoke_dns_resolver.inbound_address_prefix, null) != null && can(cidrhost(var.spoke_dns_resolver.inbound_address_prefix, 0)))
    error_message = "spoke_dns_resolver.inbound_address_prefix is required and must be a valid CIDR when the resolver is enabled."
  }

  validation {
    condition     = !var.spoke_dns_resolver.enabled || (try(var.spoke_dns_resolver.outbound_address_prefix, null) != null && can(cidrhost(var.spoke_dns_resolver.outbound_address_prefix, 0)))
    error_message = "spoke_dns_resolver.outbound_address_prefix is required and must be a valid CIDR when the resolver is enabled."
  }

  validation {
    condition = !var.spoke_dns_resolver.enabled || (
      tonumber(split("/", var.spoke_dns_resolver.inbound_address_prefix)[1]) <= 28 &&
      tonumber(split("/", var.spoke_dns_resolver.outbound_address_prefix)[1]) <= 28
    )
    error_message = "DNS Private Resolver subnets must be /28 or larger (prefix length 28 or smaller)."
  }

  validation {
    condition     = !var.spoke_dns_resolver.enabled || length(var.spoke_dns_resolver.forward_to) > 0
    error_message = "spoke_dns_resolver.forward_to must contain at least one DNS server IP when the resolver is enabled. Use the hub firewall DNS proxy, not the central resolver inbound, unless firewall policy already allows spoke-to-inbound port 53."
  }

  validation {
    condition = alltrue([
      for domain in var.spoke_dns_resolver.additional_forward_domains :
      can(regex("^[a-zA-Z0-9._-]+\\.?$", domain)) && domain != "."
    ])
    error_message = "Each additional_forward_domains value must be a DNS suffix other than the catch-all '.' rule."
  }

}

variable "dns_forwarding_ruleset_id" {
  description = "Optional existing central DNS forwarding ruleset ID to link to the expansion VNet (Azure-provided DNS / slimmer platform variant). The ruleset must forward queries to a resolver inbound whose VNet is linked to the central private zones, and must not itself be linked to that inbound VNet. Mutually exclusive with spoke_dns_resolver.enabled."
  type        = string
  default     = null
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
  description = "Create the module's baseline NSG rules (Azure Load Balancer inbound, VNet outbound, deny Internet inbound, default egress in nat/firewall_snat/private_nat when 0.0.0.0/0 is routed, Internet deny in none, and optional enterprise-route outbound). Disable only when supplying a complete custom rule set."
  type        = bool
  default     = true
}

variable "tags" {
  description = "(Optional) Additional tags to merge with the isolated_expansion classification tags."
  type        = map(string)
  default     = {}
}
