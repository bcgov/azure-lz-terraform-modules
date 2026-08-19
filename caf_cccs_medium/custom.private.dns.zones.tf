## IMPORTANT
# The Private DNS code is a cyclical reference when deployed with the CAF
# For example, the CAF needs to deploy vWAN first,
# then we need a Vending Spoke for the Private DNS Resolvers,
# then we need to update the vWAN with the Private DNS Resolver's VNet ID to link the Private DNS Zones.
# This custom Private DNS Zone inclusion has the same challenge, where it needs the Private DNS Resolver VNet ID to link the Private DNS Zones.

module "lz_custom_private_dns_zones" {
  source = "../azure_private_dns/private_dns_zone"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  private_dns_zones = var.private_dns_zones
}

module "private_dns_zone_virtual_network_link" {
  source = "../azure_private_dns/private_dns_zone_virtual_network_link"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  private_dns_zone_virtual_network_link = var.private_dns_zone_virtual_network_link

  depends_on = [module.lz_custom_private_dns_zones]
}
