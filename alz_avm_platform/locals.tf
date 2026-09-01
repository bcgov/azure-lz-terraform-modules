locals {
  address_ranges_yaml = file("${path.module}/address_ranges.yaml")
  address_ranges_map  = yamldecode(local.address_ranges_yaml)

  rfc_1918_address_ranges   = local.address_ranges_map["rfc_1918_address_ranges"]
  onpremises_address_ranges = local.address_ranges_map["onpremises_address_ranges"]
  azure_address_ranges      = local.address_ranges_map["azure_address_ranges"]

  onprem_dns_server_ips                     = local.address_ranges_map["onprem_dns_server_ips"]
  github_actions_ip_ranges                  = local.address_ranges_map["github_actions_ip_ranges"]
  github_enterprise_ip_ranges               = local.address_ranges_map["github_enterprise_ip_ranges"]
  github_runners_vnet_address_range         = local.address_ranges_map["github_runners_vnet_address_range"]
  github_runners_target_vnet_address_ranges = local.address_ranges_map["github_runners_target_vnet_address_ranges"]
}
