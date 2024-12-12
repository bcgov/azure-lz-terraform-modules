resource "azurerm_vpn_gateway_connection" "this" {
  name               = var.vpn_gateway_connection_name
  remote_vpn_site_id = var.remote_vpn_site_id
  vpn_gateway_id     = var.vpn_gateway_id

  dynamic "vpn_link" {
    for_each = var.vpn_link

    content {
      name             = vpn_link.value.name
      egress_nat_rule_ids = vpn_link.value.egress_nat_rule_ids
      ingress_nat_rule_ids = vpn_link.value.ingress_nat_rule_ids
      vpn_site_link_id = vpn_link.value.vpn_site_link_id
      bandwidth_mbps   = vpn_link.value.bandwidth_mbps
      bgp_enabled      = vpn_link.value.bgp_enabled
      connection_mode  = vpn_link.value.connection_mode

      dynamic "ipsec_policy" {
        for_each = vpn_link.value.ipsec_policy != null ? vpn_link.value.ipsec_policy : []

        content {
          dh_group               = ipsec_policy.value.dh_group
          ike_encryption_algorithm = ipsec_policy.value.ike_encryption_algorithm
          ike_integrity_algorithm  = ipsec_policy.value.ike_integrity_algorithm
          encryption_algorithm     = ipsec_policy.value.encryption_algorithm
          integrity_algorithm      = ipsec_policy.value.integrity_algorithm
          pfs_group                = ipsec_policy.value.pfs_group
          sa_data_size_kb          = ipsec_policy.value.sa_data_size_kb
          sa_lifetime_sec      = ipsec_policy.value.sa_lifetime_sec
        }
      }

      protocol         = vpn_link.value.protocol
      ratelimit_enabled = vpn_link.value.ratelimit_enabled
      route_weight     = vpn_link.value.route_weight
      shared_key       = vpn_link.value.shared_key
      local_azure_ip_address_enabled = vpn_link.value.local_azure_ip_address_enabled
      policy_based_traffic_selector_enabled = vpn_link.value.policy_based_traffic_selector_enabled

      dynamic "custom_bgp_address" {
        for_each = vpn_link.value.custom_bgp_address != null ? [vpn_link.value.custom_bgp_address] : []

        content {
          ip_address          = custom_bgp_address.value.ip_address
          ip_configuration_id = custom_bgp_address.value.ip_configuration_id
        }
      }
    }
  }

  internet_security_enabled = var.internet_security_enabled

  dynamic "routing" {
    for_each = var.routing != null ? [var.routing] : []

    content {
      associated_route_table = routing.value.associated_route_table

      dynamic "propagated_route_table" {
        for_each = routing.value.propagated_route_table != null ? [routing.value.propagated_route_table] : []

        content {
          route_table_ids = propagated_route_table.value.route_table_ids
          labels          = propagated_route_table.value.labels
        }
      }

      inbound_route_map_id  = routing.value.inbound_route_map_id
      outbound_route_map_id = routing.value.outbound_route_map_id
    }
  }

  dynamic "traffic_selector_policy" {
    for_each = var.traffic_selector_policy != null ? var.traffic_selector_policy : []

    content {
      local_address_ranges  = traffic_selector_policy.value.local_address_ranges
      remote_address_ranges = traffic_selector_policy.value.remote_address_ranges
    }
  }
}