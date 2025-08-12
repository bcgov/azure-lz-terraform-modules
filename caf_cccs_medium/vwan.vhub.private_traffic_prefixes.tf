
module "lz_vwan_vhub_routing_private_traffic_prefixes" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_vwan/routing_intent_and_policies?ref=vwan-private-traffic-prefixes"
  source = "../azure_vwan/routing_intent_and_policies" # Local path for testing

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  # /subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-connectivity/providers/Microsoft.Network/virtualHubs/bcgov-managed-lz-forge-hub-canadacentral
  vhub_resource_id = format(
    "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualHubs/%s",
    var.subscription_id_connectivity,
    "${var.root_id}-connectivity",
    "${var.root_id}-hub-${lower(var.primary_location)}"
  )
  # vhub_resource_id = module.connectivity.configuration.settings.vwan_hub_networks.id
  # /subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-connectivity/providers/Microsoft.Network/azureFirewalls/bcgov-managed-lz-forge-fw-hub-canadacentral
  firewall_resource_id = format(
    "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/azureFirewalls/%s",
    var.subscription_id_connectivity,
    "${var.root_id}-connectivity",
    "${var.root_id}-fw-hub-${lower(var.primary_location)}"
  )
  # firewall_resource_id = module.connectivity.configuration.settings.firewalls[0].id

  onpremises_address_ranges = var.onpremises_address_ranges
}
