locals {
  address_ranges_yaml = file("${path.module}/address_ranges.yaml")
  address_ranges_map  = yamldecode(local.address_ranges_yaml)

  rfc_1918_address_ranges = local.address_ranges_map["rfc_1918_address_ranges"]
  onpremises_address_ranges = local.address_ranges_map["onpremises_address_ranges"]
  azure_address_ranges = local.address_ranges_map["azure_address_ranges"]

  vhub_resource_id = "/subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-connectivity/providers/Microsoft.Network/virtualHubs/bcgov-managed-lz-forge-hub-canadacentral"
  firewall_resource_id = "/subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-connectivity/providers/Microsoft.Network/azureFirewalls/bcgov-managed-lz-forge-fw-hub-canadacentral"
}