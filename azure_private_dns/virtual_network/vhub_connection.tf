resource "azurerm_virtual_hub_connection" "this" {
  name                      = "vhc-hub_to_privatedns-spoke"
  virtual_hub_id            = data.azurerm_virtual_hub.vwan_hub.id
  remote_virtual_network_id = azurerm_virtual_network.this.id
}