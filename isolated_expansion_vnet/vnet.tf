resource "azurerm_virtual_network" "this" {
  name                = local.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = local.dns_servers

  private_endpoint_vnet_policies = "Disabled"

  dynamic "subnet" {
    for_each = var.subnets

    content {
      name             = local.subnet_name[subnet.key]
      address_prefixes = [subnet.value.address_prefix]
      security_group   = try(local.subnet_nsg_id[subnet.key], null)

      service_endpoints                             = subnet.value.service_endpoints
      private_endpoint_network_policies             = subnet.value.private_endpoint_network_policies
      private_link_service_network_policies_enabled = subnet.value.private_link_service_network_policies_enabled
      default_outbound_access_enabled               = subnet.value.default_outbound_access_enabled
      route_table_id                                = subnet.value.associate_route_table ? local.egress_route_table_id : null

      delegation = subnet.value.delegation == null ? [] : [
        {
          name = coalesce(subnet.value.delegation.name, replace(subnet.value.delegation.service_name, "/", "-"))
          service_delegation = [
            {
              name    = subnet.value.delegation.service_name
              actions = subnet.value.delegation.actions
            }
          ]
        }
      ]
    }
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = !local.address_space_overlaps_known_ranges
      error_message = "Expansion address_space overlaps the routable workload VNet or a disallowed address space."
    }

    precondition {
      condition     = local.subnets_contained_in_address_space
      error_message = "One or more subnet prefixes are outside the expansion VNet address_space."
    }

    precondition {
      condition     = !local.subnets_overlap
      error_message = "Subnet address prefixes overlap."
    }

    precondition {
      condition     = local.egress_mode != "firewall_snat" || local.firewall != null
      error_message = "Firewall configuration is required when using firewall_snat."
    }

    precondition {
      condition     = local.egress_mode != "firewall_snat" || try(local.firewall.direct_peer_bypass, true) || length(var.routable_vnet.address_space) > 0
      error_message = "routable_vnet.address_space is required when direct_peer_bypass is false so peer prefixes can be steered to the firewall."
    }

    precondition {
      condition     = local.egress_mode != "private_nat" || local.private_nat != null
      error_message = "egress.private_nat is required when using private_nat."
    }

    precondition {
      condition     = !local.private_nat_enabled || local.private_nat_subnet_in_spoke
      error_message = "egress.private_nat.subnet_address_prefix must be contained in routable_vnet.address_space."
    }

    precondition {
      condition     = !local.private_nat_overlaps_expansion && !local.private_nat_overlaps_dns
      error_message = "egress.private_nat.subnet_address_prefix overlaps the expansion address space or a spoke DNS resolver subnet."
    }

    precondition {
      condition     = !local.allow_gateway_transit && !local.use_remote_gateways
      error_message = "Gateway transit is not supported for isolated expansion VNets."
    }

    precondition {
      condition     = !local.spoke_dns_resolver_enabled || length(var.routable_vnet.address_space) > 0
      error_message = "routable_vnet.address_space is required when spoke_dns_resolver is enabled so the inbound NSG can allow DNS from the spoke."
    }

    # Callers may add workload subnets outside this module when var.subnets is empty.
    ignore_changes = [tags, subnet]
  }
}
