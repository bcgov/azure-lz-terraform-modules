resource "azurerm_virtual_network_peering" "expansion_to_routable" {
  name                         = local.peering_from_expansion_name
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = var.routable_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = local.allow_forwarded_traffic
  allow_gateway_transit        = local.allow_gateway_transit
  use_remote_gateways          = local.use_remote_gateways

  triggers = {
    local_address_space  = join(",", var.address_space)
    remote_address_space = join(",", var.routable_vnet.address_space)
  }

  lifecycle {
    precondition {
      condition     = !local.allow_gateway_transit && !local.use_remote_gateways
      error_message = "Gateway transit is not supported for isolated expansion VNets."
    }
  }
}

resource "azurerm_virtual_network_peering" "routable_to_expansion" {
  name                         = local.peering_from_routable_name
  resource_group_name          = var.routable_vnet.resource_group_name
  virtual_network_name         = var.routable_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.this.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = local.allow_forwarded_traffic
  allow_gateway_transit        = local.allow_gateway_transit
  use_remote_gateways          = local.use_remote_gateways

  triggers = {
    local_address_space  = join(",", var.routable_vnet.address_space)
    remote_address_space = join(",", var.address_space)
  }

  depends_on = [azurerm_virtual_network_peering.expansion_to_routable]
}
