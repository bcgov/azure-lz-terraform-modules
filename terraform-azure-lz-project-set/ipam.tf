locals {
  address_sizes_by_subscription = merge([
    for k, v in var.subscriptions :
    { for i, j in v.network.address_sizes : "${k}-${i}" => j }
    if try(v.network.enabled, false) && length(try(v.network.address_sizes, {})) > 0
  ]...)

  ipam_reservations_by_subscription = {
    for k, v in var.subscriptions :
    k => compact(concat([""], flatten([for i, _ in v.network.address_sizes : compact(concat([""], flatten(lookup(azurerm_network_manager_ipam_pool_static_cidr.reservations["${k}-${i}"], "address_prefixes", []))))])))
    if try(v.network.enabled, false) && length(try(v.network.address_sizes, {})) > 0
  }

}

resource "azurerm_network_manager_ipam_pool_static_cidr" "reservations" {
  for_each                           = local.address_sizes_by_subscription
  name                               = "${var.license_plate}-${each.key}"
  ipam_pool_id                       = var.network_manager_ipam_pool_id
  number_of_ip_addresses_to_allocate = each.value
}
