resource "azurerm_network_manager_ipam_pool_static_cidr" "reservations" {
  name                               = "github-managed-runners-vnet"
  ipam_pool_id                       = var.network_manager_ipam_pool_id
  number_of_ip_addresses_to_allocate = pow(2, 32 - var.virtual_network_address_space)
}
