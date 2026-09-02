locals {
  private_dns_zones_resource_group_name = provider::azapi::parse_resource_id(
    "Microsoft.Resources/resourceGroups",
    values(var.virtual_hubs)[0].private_dns_zones.parent_id
  ).resource_group_name
}
