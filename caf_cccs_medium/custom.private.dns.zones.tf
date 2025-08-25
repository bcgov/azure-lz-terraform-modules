## IMPORTANT
# The Private DNS code is a cyclical reference when deployed with the CAF
# For example, the CAF needs to deploy vWAN first,
# then we need a Vending Spoke for the Private DNS Resolvers,
# then we need to update the vWAN with the Private DNS Resolver's VNet ID to link the Private DNS Zones.
# This custom Private DNS Zone inclusion has the same challenge, where it needs the Private DNS Resolver VNet ID to link the Private DNS Zones.

module "lz_custom_private_dns_zones" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_private_dns/private_dns_zone?ref=v0.0.17"
  source = "../azure_private_dns/private_dns_zone" # NOTE: For local testing only, replace with the above for production

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  private_dns_zones = var.private_dns_zones
}

module "private_dns_zone_virtual_network_link" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_private_dns/private_dns_zone_virtual_network_link?ref=v0.0.17"
  source = "../azure_private_dns/private_dns_zone_virtual_network_link" # NOTE: For local testing only, replace with the above for production

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  private_dns_zone_virtual_network_link = var.private_dns_zone_virtual_network_link
}
