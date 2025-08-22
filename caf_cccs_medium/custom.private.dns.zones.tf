module "lz_custom_private_dns_zones" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_private_dns/private_dns_zone?ref=v0.0.13"
  source = "../azure_private_dns/private_dns_zone"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  private_dns_zones = var.private_dns_zones
}

module "private_dns_zone_virtual_network_link" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_private_dns/private_dns_zone?ref=v0.0.13"
  source = "../azure_private_dns/private_dns_zone_virtual_network_link"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  private_dns_zone_virtual_network_link = var.private_dns_zone_virtual_network_link
}
