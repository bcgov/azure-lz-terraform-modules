locals {
  associated_route_table_id = coalesce(
    var.associated_route_table_id,
    "${var.virtual_hub_id}/hubRouteTables/defaultRouteTable",
  )

  propagated_route_table_id = coalesce(
    var.propagated_route_table_id,
    "${var.virtual_hub_id}/hubRouteTables/noneRouteTable",
  )

  route_maps = {
    (var.outbound_route_map_key) = {
      name = var.outbound_route_map_name
      rules = [
        {
          name                 = "drop-onprem-asn"
          next_step_if_matched = "Terminate"
          match_criteria = [
            {
              match_condition = "Contains"
              as_path         = var.onprem_bgp_asns
            }
          ]
          actions = [
            {
              type = "Drop"
            }
          ]
        }
      ]
    }
  }

  outbound_route_map_id = module.route_maps.route_map_ids[var.outbound_route_map_key]

  # ARM routingConfiguration body shared by VPN and ExpressRoute connections.
  connection_routing = {
    associatedRouteTable = {
      id = local.associated_route_table_id
    }
    propagatedRouteTables = {
      labels = var.propagated_route_table_labels
      ids = [
        {
          id = local.propagated_route_table_id
        }
      ]
    }
    outboundRouteMap = {
      id = local.outbound_route_map_id
    }
  }
}
