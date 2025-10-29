# IMPORTANT: The provider status of the Express Route Circuit must be set as provisioned while creating the Express Route circuit peering.
resource "azurerm_express_route_circuit_peering" "this" {
  for_each = { for peering in var.circuit_peering : "${peering.express_route_circuit_name}-${peering.peering_type}" => peering }

  peering_type               = each.value.peering_type
  express_route_circuit_name = each.value.express_route_circuit_name
  resource_group_name        = var.resource_group_name

  vlan_id                       = each.value.vlan_id
  primary_peer_address_prefix   = each.value.primary_peer_address_prefix
  secondary_peer_address_prefix = each.value.secondary_peer_address_prefix
  ipv4_enabled                  = each.value.ipv4_enabled

  shared_key      = each.value.shared_key
  peer_asn        = each.value.peer_asn
  route_filter_id = each.value.route_filter_id

  dynamic "microsoft_peering_config" {
    for_each = each.value.microsoft_peering_config != null ? [each.value.microsoft_peering_config] : []
    content {
      advertised_public_prefixes = microsoft_peering_config.advertised_public_prefixes
      customer_asn               = microsoft_peering_config.customer_asn
      routing_registry_name      = microsoft_peering_config.routing_registry_name
      advertised_communities     = microsoft_peering_config.advertised_communities
    }
  }
}
