
# IMPORTANT: The provider status of the Express Route Circuit must be set as provisioned while creating the Express Route Connection.
resource "azurerm_express_route_connection" "this" {
  name                                 = var.express_route_connection_name
  express_route_circuit_peering_id     = local.express_route_circuit_peering_id
  express_route_gateway_id             = local.express_route_gateway_id
  authorization_key                    = var.authorization_key
  enable_internet_security             = var.enable_internet_security
  express_route_gateway_bypass_enabled = var.express_route_gateway_bypass_enabled
  private_link_fast_path_enabled       = var.private_link_fast_path_enabled
  routing_weight                       = var.routing_weight

  dynamic "routing" {
    for_each = var.routing != null ? [var.routing] : []
    content {
      associated_route_table_id = routing.value.associated_route_table_id
      inbound_route_map_id      = routing.value.inbound_route_map_id
      outbound_route_map_id     = routing.value.outbound_route_map_id

      propagated_route_table {
        labels          = try(routing.value.propagated_route_table.labels, [])
        route_table_ids = try(routing.value.propagated_route_table.route_table_ids, [])
      }
    }
  }
}
