resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_express_route_circuit" "this" {
  name                     = var.express_route_circuit_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  service_provider_name    = var.service_provider_name
  peering_location         = var.peering_location
  bandwidth_in_mbps        = var.bandwidth_in_mbps
  allow_classic_operations = var.allow_classic_operations

  sku {
    tier   = var.sku.tier
    family = var.sku.family
  }

  tags = var.tags
}

resource "azurerm_express_route_circuit_peering" "this" {
  peering_type               = var.peering_type
  express_route_circuit_name = azurerm_express_route_circuit.this.name
  resource_group_name        = azurerm_resource_group.this.name

  vlan_id                       = var.vlan_id
  primary_peer_address_prefix   = var.primary_peer_address_prefix
  secondary_peer_address_prefix = var.secondary_peer_address_prefix
  ipv4_enabled                  = var.ipv4_enabled

  shared_key      = var.shared_key
  peer_asn        = var.peer_asn
  route_filter_id = var.route_filter_id

  microsoft_peering_config {
    advertised_public_prefixes = var.microsoft_peering_config.advertised_public_prefixes
    customer_asn               = var.microsoft_peering_config.customer_asn
    routing_registry_name      = var.microsoft_peering_config.routing_registry_name
    advertised_communities     = var.microsoft_peering_config.advertised_communities
  }
}
