# resource "azurerm_virtual_hub_connection" "this" {
#   name                      = "vhc-hub_to_github-managed-runners"
#   virtual_hub_id            = data.azurerm_virtual_hub.vwan_hub.id
#   remote_virtual_network_id = azurerm_virtual_network.ghrunners_vnet.id

#   internet_security_enabled = true #TODO: Update this to be a variable, which will require updating the consuming modules

#   lifecycle {
#     ignore_changes = [
#       routing
#     ]
#   }
# }
