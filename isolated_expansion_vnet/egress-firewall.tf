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
    error_message = "enterprise_routes are ignored when egress.mode is none. Use firewall_snat if residual Databricks or enterprise platform endpoints still require a translated path."
  }
}
