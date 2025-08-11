
module "lz_vwan_vhub_routing_private_traffic_prefixes" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_vwan/routing_intent_and_policies?ref=vwan-private-traffic-prefixes"
  source = "../azure_vwan/routing_intent_and_policies" # Local path for testing

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  vhub_resource_id = module.connectivity.configuration.settings.vwan_hub_networks.id
  firewall_resource_id = module.connectivity.configuration.settings.firewalls[0].id

  onpremises_address_ranges = var.onpremises_address_ranges
}