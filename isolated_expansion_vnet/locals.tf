locals {
  virtual_network_name = coalesce(var.virtual_network_name, var.name)

  classification_tags = {
    network_classification = "isolated_expansion"
    isolated_address_space = "true"
  }

  tags = merge(local.classification_tags, var.tags)

  egress_mode         = var.egress.mode
  nat_enabled         = local.egress_mode == "nat"
  firewall_enabled    = local.egress_mode == "firewall_snat"
  private_nat_enabled = local.egress_mode == "private_nat"
  none_enabled        = local.egress_mode == "none"
  appliance_enabled   = local.firewall_enabled || local.private_nat_enabled
  internet_egress_enabled = local.nat_enabled || (
    local.firewall_enabled && try(var.egress.firewall.route_internet_through_firewall, true)
    ) || (
    local.private_nat_enabled && try(var.egress.private_nat.route_internet_through_nva, true)
  )

  nat = var.egress.nat

  firewall    = local.firewall_enabled ? var.egress.firewall : null
  private_nat = local.private_nat_enabled ? var.egress.private_nat : null

  private_nat_ip = local.private_nat_enabled ? coalesce(
    local.private_nat.private_ip,
    cidrhost(local.private_nat.subnet_address_prefix, 4)
  ) : null

  private_nat_patch_schedule         = local.private_nat_enabled ? try(local.private_nat.patch_schedule, null) : null
  private_nat_patch_schedule_enabled = local.private_nat_patch_schedule != null

  firewall_ip = local.firewall_enabled ? coalesce(
    local.firewall.private_ip,
    cidrhost(local.firewall.subnet_address_prefix, 4)
  ) : null

  firewall_subnets = local.firewall_enabled ? {
    data = {
      name           = "AzureFirewallSubnet"
      address_prefix = local.firewall.subnet_address_prefix
      route_table_id = local.firewall.spoke_route_table_id
    }
    management = {
      name           = "AzureFirewallManagementSubnet"
      address_prefix = local.firewall.management_subnet_address_prefix
      route_table_id = null
    }
  } : {}

  private_nat_subnet_name = local.private_nat_enabled ? coalesce(
    local.private_nat.subnet_name,
    "nva-${local.virtual_network_name}"
  ) : null

  private_nat_ssh_sources = local.private_nat_enabled ? distinct(concat(
    local.private_nat.ssh_source_prefixes,
    var.routable_vnet.address_space
  )) : []

  private_nat_image = local.private_nat_enabled ? {
    publisher = coalesce(try(local.private_nat.image.publisher, null), "Canonical")
    offer     = coalesce(try(local.private_nat.image.offer, null), "ubuntu-26_04-lts")
    sku       = coalesce(try(local.private_nat.image.sku, null), "server-gen1")
    version   = coalesce(try(local.private_nat.image.version, null), "latest")
  } : null

  allow_forwarded_traffic = local.appliance_enabled
  allow_gateway_transit   = false
  use_remote_gateways     = false

  spoke_dns_resolver_enabled = var.spoke_dns_resolver.enabled
  spoke_dns_resolver_inbound_ip = local.spoke_dns_resolver_enabled ? coalesce(
    var.spoke_dns_resolver.inbound_ip,
    cidrhost(var.spoke_dns_resolver.inbound_address_prefix, 4)
  ) : null

  dns_servers = local.spoke_dns_resolver_enabled ? [local.spoke_dns_resolver_inbound_ip] : (
    var.dns.mode == "custom" ? var.dns.servers : null
  )

  subnet_keys = keys(var.subnets)

  subnet_pairs = flatten([
    for i, a in local.subnet_keys : [
      for j, b in local.subnet_keys : {
        a = var.subnets[a].address_prefix
        b = var.subnets[b].address_prefix
      } if i < j
    ]
  ])

  known_other_cidrs = concat(var.routable_vnet.address_space, var.disallowed_address_spaces)
  extra_spoke_cidrs = compact(concat(
    try(var.egress.private_nat.subnet_address_prefix, null) != null ? [var.egress.private_nat.subnet_address_prefix] : [],
    try(var.egress.firewall.subnet_address_prefix, null) != null ? [
      var.egress.firewall.subnet_address_prefix,
      var.egress.firewall.management_subnet_address_prefix
    ] : [],
    local.spoke_dns_resolver_enabled ? [
      var.spoke_dns_resolver.inbound_address_prefix,
      var.spoke_dns_resolver.outbound_address_prefix
    ] : []
  ))
  cidrs_for_range = distinct(concat(
    var.address_space,
    local.known_other_cidrs,
    [for s in var.subnets : s.address_prefix],
    local.extra_spoke_cidrs,
    var.enterprise_routes
  ))

  # HashiCorp Terraform has no cidrcontains; compare IPv4 ranges numerically.
  ipv4_num = {
    for cidr in local.cidrs_for_range : cidr => {
      start = (
        tonumber(split(".", cidrhost(cidr, 0))[0]) * 16777216 +
        tonumber(split(".", cidrhost(cidr, 0))[1]) * 65536 +
        tonumber(split(".", cidrhost(cidr, 0))[2]) * 256 +
        tonumber(split(".", cidrhost(cidr, 0))[3])
      )
      end = (
        tonumber(split(".", cidrhost(cidr, -1))[0]) * 16777216 +
        tonumber(split(".", cidrhost(cidr, -1))[1]) * 65536 +
        tonumber(split(".", cidrhost(cidr, -1))[2]) * 256 +
        tonumber(split(".", cidrhost(cidr, -1))[3])
      )
    }
  }

  cidrs_overlap = flatten([
    for left in var.address_space : [
      for right in local.known_other_cidrs : {
        left  = left
        right = right
      } if local.ipv4_num[left].start <= local.ipv4_num[right].end && local.ipv4_num[right].start <= local.ipv4_num[left].end
    ]
  ])

  address_space_overlaps_known_ranges = length(local.cidrs_overlap) > 0

  subnets_contained_in_address_space = alltrue([
    for s in var.subnets : anytrue([
      for vnet_cidr in var.address_space :
      local.ipv4_num[s.address_prefix].start >= local.ipv4_num[vnet_cidr].start &&
      local.ipv4_num[s.address_prefix].end <= local.ipv4_num[vnet_cidr].end
    ])
  ])

  subnets_overlap = anytrue([
    for pair in local.subnet_pairs :
    local.ipv4_num[pair.a].start <= local.ipv4_num[pair.b].end && local.ipv4_num[pair.b].start <= local.ipv4_num[pair.a].end
  ])

  private_nat_subnet_in_spoke = !local.private_nat_enabled || anytrue([
    for vnet_cidr in var.routable_vnet.address_space :
    local.ipv4_num[local.private_nat.subnet_address_prefix].start >= local.ipv4_num[vnet_cidr].start &&
    local.ipv4_num[local.private_nat.subnet_address_prefix].end <= local.ipv4_num[vnet_cidr].end
  ])

  private_nat_overlaps_expansion = local.private_nat_enabled && anytrue([
    for left in var.address_space :
    local.ipv4_num[left].start <= local.ipv4_num[local.private_nat.subnet_address_prefix].end &&
    local.ipv4_num[local.private_nat.subnet_address_prefix].start <= local.ipv4_num[left].end
  ])

  private_nat_overlaps_dns = local.private_nat_enabled && local.spoke_dns_resolver_enabled && anytrue([
    for dns_cidr in [var.spoke_dns_resolver.inbound_address_prefix, var.spoke_dns_resolver.outbound_address_prefix] :
    local.ipv4_num[local.private_nat.subnet_address_prefix].start <= local.ipv4_num[dns_cidr].end &&
    local.ipv4_num[dns_cidr].start <= local.ipv4_num[local.private_nat.subnet_address_prefix].end
  ])

  private_nat_ip_num = local.private_nat_enabled ? (
    tonumber(split(".", local.private_nat_ip)[0]) * 16777216 +
    tonumber(split(".", local.private_nat_ip)[1]) * 65536 +
    tonumber(split(".", local.private_nat_ip)[2]) * 256 +
    tonumber(split(".", local.private_nat_ip)[3])
  ) : null

  private_nat_ip_in_subnet = !local.private_nat_enabled || (
    local.private_nat_ip_num >= local.ipv4_num[local.private_nat.subnet_address_prefix].start + 4 &&
    local.private_nat_ip_num <= local.ipv4_num[local.private_nat.subnet_address_prefix].end - 1
  )

  enterprise_routes_overlap_expansion = anytrue(flatten([
    for left in var.address_space : [
      for right in var.enterprise_routes :
      local.ipv4_num[left].start <= local.ipv4_num[right].end &&
      local.ipv4_num[right].start <= local.ipv4_num[left].end
    ]
  ]))

  firewall_subnet_in_spoke = !local.firewall_enabled || alltrue([
    for prefix in [local.firewall.subnet_address_prefix, local.firewall.management_subnet_address_prefix] : anytrue([
      for vnet_cidr in var.routable_vnet.address_space :
      local.ipv4_num[prefix].start >= local.ipv4_num[vnet_cidr].start &&
      local.ipv4_num[prefix].end <= local.ipv4_num[vnet_cidr].end
    ])
  ])

  firewall_subnets_overlap = local.firewall_enabled && (
    local.ipv4_num[local.firewall.subnet_address_prefix].start <= local.ipv4_num[local.firewall.management_subnet_address_prefix].end &&
    local.ipv4_num[local.firewall.management_subnet_address_prefix].start <= local.ipv4_num[local.firewall.subnet_address_prefix].end
  )

  firewall_overlaps_expansion = local.firewall_enabled && anytrue(flatten([
    for prefix in [local.firewall.subnet_address_prefix, local.firewall.management_subnet_address_prefix] : [
      for left in var.address_space :
      local.ipv4_num[left].start <= local.ipv4_num[prefix].end &&
      local.ipv4_num[prefix].start <= local.ipv4_num[left].end
    ]
  ]))

  firewall_overlaps_dns = local.firewall_enabled && local.spoke_dns_resolver_enabled && anytrue(flatten([
    for prefix in [local.firewall.subnet_address_prefix, local.firewall.management_subnet_address_prefix] : [
      for dns_cidr in [var.spoke_dns_resolver.inbound_address_prefix, var.spoke_dns_resolver.outbound_address_prefix] :
      local.ipv4_num[prefix].start <= local.ipv4_num[dns_cidr].end &&
      local.ipv4_num[dns_cidr].start <= local.ipv4_num[prefix].end
    ]
  ]))

  firewall_overlaps_nva = local.firewall_enabled && try(var.egress.private_nat.subnet_address_prefix, null) != null && anytrue([
    for prefix in [local.firewall.subnet_address_prefix, local.firewall.management_subnet_address_prefix] :
    local.ipv4_num[prefix].start <= local.ipv4_num[var.egress.private_nat.subnet_address_prefix].end &&
    local.ipv4_num[var.egress.private_nat.subnet_address_prefix].start <= local.ipv4_num[prefix].end
  ])

  firewall_ip_num = local.firewall_enabled ? (
    tonumber(split(".", local.firewall_ip)[0]) * 16777216 +
    tonumber(split(".", local.firewall_ip)[1]) * 65536 +
    tonumber(split(".", local.firewall_ip)[2]) * 256 +
    tonumber(split(".", local.firewall_ip)[3])
  ) : null

  firewall_ip_in_subnet = !local.firewall_enabled || (
    local.firewall_ip_num >= local.ipv4_num[local.firewall.subnet_address_prefix].start + 4 &&
    local.firewall_ip_num <= local.ipv4_num[local.firewall.subnet_address_prefix].end - 1
  )

  subnets_needing_nsg = {
    for key, subnet in var.subnets : key => subnet if subnet.create_nsg || subnet.nsg_id != null
  }

  created_nsgs = {
    for key, subnet in var.subnets : key => subnet if subnet.create_nsg
  }

  subnet_name = {
    for key, subnet in var.subnets : key => coalesce(subnet.name, key)
  }

  subnet_nsg_id = {
    for key, subnet in local.subnets_needing_nsg : key => (
      subnet.create_nsg ? azurerm_network_security_group.this[key].id : subnet.nsg_id
    )
  }

  subnet_ids = {
    for key, name in local.subnet_name : key => "${azurerm_virtual_network.this.id}/subnets/${name}"
  }

  subnet_prefixes = {
    for key, subnet in var.subnets : key => [subnet.address_prefix]
  }

  peering_from_expansion_name = "isolated-expansion-${var.name}"
  peering_from_routable_name  = "isolated-expansion-from-${var.name}"

  dns_forwarding_ruleset_link_enabled = var.dns_forwarding_ruleset_id != null

  spoke_dns_inbound_sources = distinct(concat(var.address_space, var.routable_vnet.address_space))

  spoke_dns_additional_forward_domains = {
    for domain in var.spoke_dns_resolver.additional_forward_domains :
    replace(trimsuffix(domain, "."), ".", "-") => (
      endswith(domain, ".") ? domain : "${domain}."
    )
    if local.spoke_dns_resolver_enabled
  }

  spoke_dns_inbound_nsg_rules = {
    AllowDnsUdpInbound = {
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Udp"
      description                  = "Allow DNS from the isolated expansion VNet and the routable spoke."
      destination_port_range       = "53"
      source_address_prefix        = null
      source_address_prefixes      = local.spoke_dns_inbound_sources
      destination_address_prefix   = "VirtualNetwork"
      destination_address_prefixes = null
    }
    AllowDnsTcpInbound = {
      priority                     = 111
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      description                  = "Allow DNS from the isolated expansion VNet and the routable spoke."
      destination_port_range       = "53"
      source_address_prefix        = null
      source_address_prefixes      = local.spoke_dns_inbound_sources
      destination_address_prefix   = "VirtualNetwork"
      destination_address_prefixes = null
    }
    AllowAzureLoadBalancerInbound = {
      priority                     = 120
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      description                  = "Allow Azure Load Balancer health probes."
      destination_port_range       = "*"
      source_address_prefix        = "AzureLoadBalancer"
      source_address_prefixes      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
    DenyInternetInbound = {
      priority                     = 4096
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      description                  = "Deny inbound Internet traffic."
      destination_port_range       = "*"
      source_address_prefix        = "Internet"
      source_address_prefixes      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
  }

  spoke_dns_outbound_nsg_rules = {
    AllowDnsUdpOutbound = {
      priority                     = 110
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Udp"
      description                  = "Allow forwarded DNS to the hub DNS proxy."
      destination_port_range       = "53"
      source_address_prefix        = "*"
      source_address_prefixes      = null
      destination_address_prefix   = null
      destination_address_prefixes = var.spoke_dns_resolver.forward_to
    }
    AllowDnsTcpOutbound = {
      priority                     = 111
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      description                  = "Allow forwarded DNS to the hub DNS proxy."
      destination_port_range       = "53"
      source_address_prefix        = "*"
      source_address_prefixes      = null
      destination_address_prefix   = null
      destination_address_prefixes = var.spoke_dns_resolver.forward_to
    }
    AllowAzureLoadBalancerInbound = {
      priority                     = 120
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      description                  = "Allow Azure Load Balancer health probes."
      destination_port_range       = "*"
      source_address_prefix        = "AzureLoadBalancer"
      source_address_prefixes      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
  }

  spoke_dns_subnets = {
    inbound = {
      address_prefix = var.spoke_dns_resolver.inbound_address_prefix
      nsg_id         = one(azurerm_network_security_group.spoke_dns_inbound[*].id)
    }
    outbound = {
      address_prefix = var.spoke_dns_resolver.outbound_address_prefix
      nsg_id         = one(azurerm_network_security_group.spoke_dns_outbound[*].id)
    }
  }

  peer_bypass_routes = local.firewall_enabled && !try(local.firewall.direct_peer_bypass, true) ? var.routable_vnet.address_space : []

  internet_routes = local.firewall_enabled && try(local.firewall.route_internet_through_firewall, true) ? ["0.0.0.0/0"] : []

  firewall_route_prefixes = local.firewall_enabled ? distinct(concat(var.enterprise_routes, local.peer_bypass_routes, local.internet_routes)) : []

  firewall_routes = {
    for cidr in local.firewall_route_prefixes : cidr => {
      name                   = cidr == "0.0.0.0/0" ? "internet-via-firewall" : "enterprise-${replace(replace(cidr, "/", "-"), ".", "-")}"
      address_prefix         = cidr
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = local.firewall_ip
    }
  }

  firewall_table_routes = {
    for cidr, route in local.firewall_routes : cidr => route
    if cidr != "0.0.0.0/0"
  }

  private_nat_peer_bypass_routes = local.private_nat_enabled && !try(local.private_nat.direct_peer_bypass, true) ? var.routable_vnet.address_space : []

  private_nat_enterprise_routes = {
    for cidr in(
      local.private_nat_enabled ? distinct(concat(var.enterprise_routes, local.private_nat_peer_bypass_routes)) : []
      ) : cidr => {
      name                   = "enterprise-${replace(replace(cidr, "/", "-"), ".", "-")}"
      address_prefix         = cidr
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = local.private_nat_ip
    }
    if cidr != "0.0.0.0/0"
  }

  private_nat_nsg_rules = {
    AllowForwardedInbound = {
      priority                     = 110
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      description                  = "Allow forwarded traffic from the isolated expansion VNet so the NVA can SNAT it."
      destination_port_range       = "*"
      source_address_prefix        = null
      source_address_prefixes      = var.address_space
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
    AllowSshInbound = {
      priority                     = 120
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "Tcp"
      description                  = "Allow SSH to the private NAT NVA from the routable spoke."
      destination_port_range       = "22"
      source_address_prefix        = length(local.private_nat_ssh_sources) > 0 ? null : "VirtualNetwork"
      source_address_prefixes      = length(local.private_nat_ssh_sources) > 0 ? local.private_nat_ssh_sources : null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
    AllowAzureLoadBalancerInbound = {
      priority                     = 130
      direction                    = "Inbound"
      access                       = "Allow"
      protocol                     = "*"
      description                  = "Allow Azure Load Balancer health probes."
      destination_port_range       = "*"
      source_address_prefix        = "AzureLoadBalancer"
      source_address_prefixes      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
    AllowForwardedOutbound = {
      priority                     = 110
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "*"
      description                  = "Allow SNATed traffic from the NVA into the spoke and enterprise paths."
      destination_port_range       = "*"
      source_address_prefix        = "*"
      source_address_prefixes      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
    DenyInternetInbound = {
      priority                     = 4096
      direction                    = "Inbound"
      access                       = "Deny"
      protocol                     = "*"
      description                  = "Deny inbound Internet traffic. The NVA has no public IP."
      destination_port_range       = "*"
      source_address_prefix        = "Internet"
      source_address_prefixes      = null
      destination_address_prefix   = "*"
      destination_address_prefixes = null
    }
  }

  default_nsg_rules = var.nsg_default_rules_enabled ? merge(
    {
      AllowAzureLoadBalancerInbound = {
        priority                     = 100
        direction                    = "Inbound"
        access                       = "Allow"
        protocol                     = "*"
        description                  = "Allow Azure Load Balancer health probes."
        source_port_range            = "*"
        source_port_ranges           = null
        destination_port_range       = "*"
        destination_port_ranges      = null
        source_address_prefix        = "AzureLoadBalancer"
        source_address_prefixes      = null
        destination_address_prefix   = "*"
        destination_address_prefixes = null
      }
      AllowVNetOutbound = {
        priority                     = 200
        direction                    = "Outbound"
        access                       = "Allow"
        protocol                     = "*"
        description                  = "Allow outbound traffic to the expansion VNet and its directly peered routable VNet."
        source_port_range            = "*"
        source_port_ranges           = null
        destination_port_range       = "*"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        source_address_prefixes      = null
        destination_address_prefix   = "VirtualNetwork"
        destination_address_prefixes = null
      }
      DenyInternetInbound = {
        priority                     = 4096
        direction                    = "Inbound"
        access                       = "Deny"
        protocol                     = "*"
        description                  = "Explicitly deny inbound Internet traffic."
        source_port_range            = "*"
        source_port_ranges           = null
        destination_port_range       = "*"
        destination_port_ranges      = null
        source_address_prefix        = "Internet"
        source_address_prefixes      = null
        destination_address_prefix   = "*"
        destination_address_prefixes = null
      }
    },
    local.internet_egress_enabled ? {
      AllowInternetOutbound = {
        priority                     = 210
        direction                    = "Outbound"
        access                       = "Allow"
        protocol                     = "*"
        description                  = local.nat_enabled ? "Allow outbound Internet traffic. SNATed by the NAT Gateway." : "Allow default egress. The 0.0.0.0/0 UDR steers it to the SNAT hop. Destination is * because the Azure Internet tag does not include RFC1918."
        source_port_range            = "*"
        source_port_ranges           = null
        destination_port_range       = "*"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        source_address_prefixes      = null
        destination_address_prefix   = local.nat_enabled ? "Internet" : "*"
        destination_address_prefixes = null
      }
      } : {
      DenyInternetOutbound = {
        priority                     = 4095
        direction                    = "Outbound"
        access                       = "Deny"
        protocol                     = "*"
        description                  = "Deny Internet egress. none mode, and private_nat without route_internet_through_nva, allow only local VNet, direct peering, Private Endpoints, and optional enterprise prefixes."
        source_port_range            = "*"
        source_port_ranges           = null
        destination_port_range       = "*"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        source_address_prefixes      = null
        destination_address_prefix   = "Internet"
        destination_address_prefixes = null
      }
    }
  ) : {}

  expansion_route_table_enabled = !local.nat_enabled

  default_internet_via_appliance = (
    (local.private_nat_enabled && try(local.private_nat.route_internet_through_nva, true)) ||
    (local.firewall_enabled && try(local.firewall.route_internet_through_firewall, true))
  )
  default_internet_next_hop_type = local.default_internet_via_appliance ? "VirtualAppliance" : "None"
  default_internet_next_hop_ip = (
    local.private_nat_enabled && try(local.private_nat.route_internet_through_nva, true) ? local.private_nat_ip :
    local.firewall_enabled && try(local.firewall.route_internet_through_firewall, true) ? local.firewall_ip :
    null
  )

  egress_route_table_id = local.expansion_route_table_enabled ? azurerm_route_table.expansion[0].id : null

  associated_subnet_keys = {
    for key, subnet in var.subnets : key => subnet
    if subnet.associate_route_table && local.egress_route_table_id != null
  }

  enterprise_nsg_rules = local.appliance_enabled && length(var.enterprise_routes) > 0 ? {
    AllowEnterpriseOutbound = {
      priority                     = 220
      direction                    = "Outbound"
      access                       = "Allow"
      protocol                     = "*"
      description                  = "Allow outbound traffic to caller-supplied enterprise prefixes via the SNAT boundary."
      source_port_range            = "*"
      source_port_ranges           = null
      destination_port_range       = "*"
      destination_port_ranges      = null
      source_address_prefix        = "*"
      source_address_prefixes      = null
      destination_address_prefix   = null
      destination_address_prefixes = var.enterprise_routes
    }
  } : {}

  nsg_rules = concat(
    flatten([
      for subnet_key, subnet in local.created_nsgs : [
        for rule_key, rule in local.default_nsg_rules : {
          key        = "${subnet_key}/${rule_key}"
          subnet_key = subnet_key
          rule_name  = rule_key
          rule       = rule
        }
      ]
    ]),
    flatten([
      for subnet_key, subnet in local.created_nsgs : [
        for rule_key, rule in local.enterprise_nsg_rules : {
          key        = "${subnet_key}/${rule_key}"
          subnet_key = subnet_key
          rule_name  = rule_key
          rule       = rule
        }
      ]
    ]),
    flatten([
      for subnet_key, subnet in local.created_nsgs : [
        for rule_key, rule in merge(var.nsg_rules, subnet.nsg_rules) : {
          key        = "${subnet_key}/${rule_key}"
          subnet_key = subnet_key
          rule_name  = rule_key
          rule       = rule
        }
      ]
    ])
  )

  nsg_rules_map = {
    for item in local.nsg_rules : item.key => item
  }

  required_firewall_routes = null

  required_firewall_rules = null

  required_private_snat = local.firewall_enabled ? {
    enabled         = true
    source_prefixes = var.address_space
    snat_to         = local.firewall_ip
    } : local.private_nat_enabled ? {
    enabled         = true
    source_prefixes = var.address_space
    snat_to         = local.private_nat_ip
  } : null
}
