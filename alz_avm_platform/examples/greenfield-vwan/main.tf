module "platform" {
  source = "../../"

  primary_location       = var.primary_location
  subscription_ids       = var.subscription_ids
  tags                   = var.tags
  management_group_names = var.management_group_names
  custom_alz_library_references = var.custom_alz_library_references

  management_resource_group_name          = var.management_resource_group_name
  management_automation_account_name      = var.management_automation_account_name
  management_log_analytics_workspace_name = var.management_log_analytics_workspace_name

  virtual_wan_settings = var.virtual_wan_settings
  virtual_hubs         = var.virtual_hubs

  enable_express_route                     = var.enable_express_route
  enable_s2s_vpn                           = var.enable_s2s_vpn
  external_base_firewall_policy_id         = var.external_base_firewall_policy_id
  express_route_circuit_connections_by_hub = var.express_route_circuit_connections_by_hub
  vpn_sites_by_hub                         = var.vpn_sites_by_hub
  vpn_site_connections_by_hub              = var.vpn_site_connections_by_hub
  routing_intents_by_hub                   = var.routing_intents_by_hub
  private_dns_zones_by_hub                 = var.private_dns_zones_by_hub
  private_dns_resolver_by_hub              = var.private_dns_resolver_by_hub
  private_dns_enable_internet_fallback     = var.private_dns_enable_internet_fallback
  private_dns_resolver_virtual_network_resource_id_by_hub = var.private_dns_resolver_virtual_network_resource_id_by_hub
  enable_centralized_logging               = var.enable_centralized_logging

  policy_default_values        = var.policy_default_values
  policy_assignments_to_modify = local.policy_assignments_to_modify

  enable_amba      = var.enable_amba
  enable_telemetry = false
}
