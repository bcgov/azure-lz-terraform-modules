# Firewall SNAT mode uses an existing enterprise-routable firewall as the
# translation boundary. This module does not create firewalls, modify shared
# firewall policy, or connect the expansion VNet to vWAN.
#
# The caller (or a higher-level networking deployment) must consume
# required_firewall_routes, required_firewall_rules, and required_private_snat
# so the firewall SNATs isolated sources before packets enter the enterprise
# routing domain.

check "firewall_snat_boundary" {
  assert {
    condition     = !local.firewall_enabled || try(local.firewall.deployment_mode, "existing") == "existing"
    error_message = "Only an existing firewall is supported for isolated expansion VNets."
  }

  assert {
    condition     = !local.firewall_enabled || try(local.firewall.firewall_private_ip, null) != null
    error_message = "firewall_private_ip is required so enterprise destinations can be reached without advertising the isolated prefix."
  }
}

check "none_mode_is_private_only" {
  assert {
    condition     = !local.none_enabled || !local.nat_enabled
    error_message = "egress.mode = none must not create a NAT Gateway."
  }

  assert {
    condition     = !local.none_enabled || length(var.enterprise_routes) == 0
    error_message = "enterprise_routes are ignored when egress.mode is none. Use firewall_snat or private_nat if residual Databricks or enterprise platform endpoints still require a translated path."
  }
}

check "private_nat_boundary" {
  assert {
    condition     = !local.private_nat_enabled || local.private_nat != null
    error_message = "egress.private_nat is required when egress.mode is private_nat."
  }

  assert {
    condition     = !local.private_nat_enabled || try(local.private_nat.route_internet_through_nva, true) || length(var.enterprise_routes) > 0
    error_message = "enterprise_routes is required when private_nat is used without route_internet_through_nva. Otherwise the expansion VNet has no translated path beyond the peer."
  }

  assert {
    condition     = !local.private_nat_enabled || length(var.routable_vnet.address_space) > 0
    error_message = "routable_vnet.address_space is required when using private_nat so the NVA subnet can be validated against the spoke."
  }

  assert {
    condition     = !local.private_nat_enabled || local.private_nat_subnet_in_spoke
    error_message = "egress.private_nat.subnet_address_prefix must be contained in routable_vnet.address_space."
  }

  assert {
    condition     = !local.private_nat_overlaps_expansion
    error_message = "egress.private_nat.subnet_address_prefix must not overlap the isolated expansion address_space."
  }

  assert {
    condition     = !local.private_nat_overlaps_dns
    error_message = "egress.private_nat.subnet_address_prefix overlaps a spoke DNS resolver subnet."
  }

  assert {
    condition     = !local.private_nat_enabled || try(local.private_nat.direct_peer_bypass, true) || length(var.routable_vnet.address_space) > 0
    error_message = "routable_vnet.address_space is required when private_nat.direct_peer_bypass is false so peer prefixes can be steered to the NVA."
  }
}
