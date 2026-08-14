locals {
  virtual_network_name = coalesce(var.virtual_network_name, var.name)

  classification_tags = {
    network_classification = "isolated_expansion"
    isolated_address_space = "true"
  }

  tags = merge(local.classification_tags, var.tags)

  egress_mode      = var.egress.mode
  nat_enabled      = local.egress_mode == "nat"
  firewall_enabled = local.egress_mode == "firewall_snat"
  none_enabled     = local.egress_mode == "none"

  nat = var.egress.nat

  firewall = local.firewall_enabled ? var.egress.firewall : null

  allow_forwarded_traffic = local.firewall_enabled
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
  cidrs_for_range   = distinct(concat(var.address_space, local.known_other_cidrs, [for s in var.subnets : s.address_prefix]))

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

  peer_bypass_routes = local.firewall_enabled && !try(local.firewall.direct_peer_bypass, true) ? var.routable_vnet.address_space : []

  internet_routes = local.firewall_enabled && try(local.firewall.route_internet_through_firewall, true) ? ["0.0.0.0/0"] : []

  firewall_route_prefixes = local.firewall_enabled ? distinct(concat(var.enterprise_routes, local.peer_bypass_routes, local.internet_routes)) : []

  firewall_routes = {
    for cidr in local.firewall_route_prefixes : cidr => {
      name                   = cidr == "0.0.0.0/0" ? "internet-via-firewall" : "enterprise-${replace(replace(cidr, "/", "-"), ".", "-")}"
      address_prefix         = cidr
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = local.firewall.firewall_private_ip
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
    local.firewall_enabled && length(var.enterprise_routes) > 0 ? {
      AllowEnterpriseOutbound = {
        priority                     = 220
        direction                    = "Outbound"
        access                       = "Allow"
        protocol                     = "*"
        description                  = "Allow outbound traffic to caller-supplied enterprise prefixes via the firewall SNAT boundary."
        source_port_range            = "*"
        source_port_ranges           = null
        destination_port_range       = "*"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        source_address_prefixes      = null
        destination_address_prefix   = null
        destination_address_prefixes = var.enterprise_routes
      }
    } : {},
    !local.none_enabled ? {
      AllowInternetOutbound = {
        priority                     = 210
        direction                    = "Outbound"
        access                       = "Allow"
        protocol                     = "*"
        description                  = "Allow outbound Internet traffic. In NAT mode this is SNATed by the NAT Gateway; in firewall mode it is steered by UDR."
        source_port_range            = "*"
        source_port_ranges           = null
        destination_port_range       = "*"
        destination_port_ranges      = null
        source_address_prefix        = "*"
        source_address_prefixes      = null
        destination_address_prefix   = "Internet"
        destination_address_prefixes = null
      }
      } : {
      DenyInternetOutbound = {
        priority                     = 4095
        direction                    = "Outbound"
        access                       = "Deny"
        protocol                     = "*"
        description                  = "Deny Internet egress. none mode allows only local VNet, direct peering, and Private Endpoint paths."
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

  egress_route_table_id = local.firewall_enabled ? azurerm_route_table.firewall[0].id : (
    local.none_enabled ? azurerm_route_table.none[0].id : null
  )

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

  required_firewall_routes = local.firewall_enabled ? [
    for route in local.firewall_routes : {
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = route.next_hop_in_ip_address
    }
  ] : null

  required_firewall_rules = local.firewall_enabled ? {
    sources      = var.address_space
    destinations = var.enterprise_routes
  } : null

  required_private_snat = local.firewall_enabled ? {
    enabled         = true
    source_prefixes = var.address_space
    snat_to         = local.firewall.firewall_private_ip
  } : null
}
