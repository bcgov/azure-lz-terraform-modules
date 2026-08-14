# Isolated expansion VNets provide additional private RFC1918 space that is
# usable inside Azure but must never become part of the enterprise routing
# domain. This module therefore never creates a vWAN connection, never enables
# gateway transit, and never advertises the expansion prefix.

check "lz_vnet_name_classification" {
  assert {
    condition     = endswith(local.virtual_network_name, "-isolated-expansion")
    error_message = "This landing zone's Deny-VNet-Creation policy allows isolated expansion VNets only when the name ends with -isolated-expansion. Do not use a *-vwan-spoke name; that pattern is reserved for enterprise-routed spokes."
  }
}

check "isolated_expansion_invariants" {
  assert {
    condition     = !local.allow_gateway_transit && !local.use_remote_gateways
    error_message = "Gateway transit and remote gateways are not supported for isolated expansion VNets."
  }

  assert {
    condition     = !local.address_space_overlaps_known_ranges
    error_message = "Expansion address_space overlaps the routable workload VNet or a disallowed address space."
  }

  assert {
    condition     = local.subnets_contained_in_address_space
    error_message = "One or more subnet prefixes are outside the expansion VNet address_space."
  }

  assert {
    condition     = !local.subnets_overlap
    error_message = "Subnet address prefixes overlap."
  }
}
