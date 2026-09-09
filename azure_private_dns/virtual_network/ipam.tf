resource "azurerm_network_manager_ipam_pool_static_cidr" "private_dns_resolver" {
  name                               = "azure-private-dns-resolvers"
  ipam_pool_id                       = var.network_manager_ipam_pool_id
  number_of_ip_addresses_to_allocate = 512 # NOTE: Two /24 subnets are required for the Azure Private DNS Resolvers (https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview#virtual-network-restrictions)
}
