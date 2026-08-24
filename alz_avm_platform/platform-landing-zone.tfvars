# /*
# --- Built-in Replacements ---
# This file contains built-in replacements to avoid repeating the same hard-coded values.
# Replacements are denoted by the dollar-dollar curly braces token (e.g. $${starter_location_01}). The following details each built-in replacements that you can use:
# `starter_location_01`: This the primary an Azure location sourced from the `starter_locations` variable. This can be used to set the location of resources.
# `starter_location_02` to `starter_location_##`: These are the secondary Azure locations sourced from the `starter_locations` variable. This can be used to set the location of resources.
# `starter_location_01_short`: Short code for the primary Azure location. Defaults to the region geo_code, or short_name if no geo_code is available. Can be overridden via the starter_locations_short variable.
# `starter_location_02_short` to `starter_location_##_short`: Short codes for the secondary Azure locations. Same behavior and override rules as starter_location_01_short.
# `root_parent_management_group_id`: This is the id of the management group that the ALZ hierarchy will be nested under.
# `subscription_id_identity`: The subscription ID of the subscription to deploy the identity resources to, sourced from the variable `subscription_ids`.
# `subscription_id_connectivity`: The subscription ID of the subscription to deploy the connectivity resources to, sourced from the variable `subscription_ids`.
# `subscription_id_management`: The subscription ID of the subscription to deploy the management resources to, sourced from the variable `subscription_ids`.
# `subscription_id_security`: The subscription ID of the subscription to deploy the security resources to, sourced from the variable `subscription_ids`.
# */

# /*
# --- Starter Locations ---
# You can define the Azure regions to use throughout the configuration.
# The first location will be used as the primary location, the second as the secondary location, and so on.
# */
# starter_locations = ["CanadaCentral", "CanadaEast"]

# /*
# --- Custom Replacements ---
# You can define custom replacements to use throughout the configuration.
# */
# custom_replacements = {
#   /*
#   --- Custom Name Replacements ---
#   You can define custom names and other strings to use throughout the configuration.
#   You can only use the built in replacements in this section.
#   NOTE: You cannot refer to another custom name in this variable.
#   */
#   names = {
#     # Defender email security contact
#     defender_email_security_contact = "replace_me@replace_me.com"

#     # Resource provisioning global connectivity
#     ddos_protection_plan_enabled = true

#     # Resource provisioning primary connectivity
#     primary_firewall_enabled                              = true
#     primary_firewall_sku_tier                             = "Premium"
#     primary_virtual_network_gateway_express_route_enabled = true
#     primary_virtual_network_gateway_vpn_enabled           = true
#     primary_private_dns_zones_enabled                     = true
#     primary_private_dns_auto_registration_zone_enabled    = true
#     primary_private_dns_resolver_enabled                  = true
#     primary_bastion_enabled                               = true
#     primary_sidecar_virtual_network_enabled               = true

#     # Resource provisioning secondary connectivity
#     secondary_firewall_enabled                              = true
#     secondary_firewall_sku_tier                             = "Premium"
#     secondary_virtual_network_gateway_express_route_enabled = true
#     secondary_virtual_network_gateway_vpn_enabled           = true
#     secondary_private_dns_zones_enabled                     = true
#     secondary_private_dns_auto_registration_zone_enabled    = true
#     secondary_private_dns_resolver_enabled                  = true
#     secondary_bastion_enabled                               = true
#     secondary_sidecar_virtual_network_enabled               = true

#     # Resource group names
#     management_resource_group_name                 = "rg-management-$${starter_location_01}"
#     connectivity_hub_vwan_resource_group_name      = "rg-hub-vwan-$${starter_location_01}"
#     connectivity_hub_primary_resource_group_name   = "rg-hub-$${starter_location_01}"
#     connectivity_hub_secondary_resource_group_name = "rg-hub-$${starter_location_02}"
#     dns_resource_group_name                        = "rg-hub-dns-$${starter_location_01}"
#     ddos_resource_group_name                       = "rg-hub-ddos-$${starter_location_01}"
#     asc_export_resource_group_name                 = "rg-asc-export-$${starter_location_01}"
#     service_health_alerts_resource_group_name      = "rg-service-health-alerts-$${starter_location_01}"

#     # Resource names
#     log_analytics_workspace_name            = "law-management-$${starter_location_01}"
#     ddos_protection_plan_name               = "ddos-$${starter_location_01}"
#     ama_user_assigned_managed_identity_name = "uami-management-ama-$${starter_location_01}"
#     dcr_change_tracking_name                = "dcr-change-tracking"
#     dcr_defender_sql_name                   = "dcr-defender-sql"
#     dcr_vm_insights_name                    = "dcr-vm-insights"

#     # Resource names primary connectivity
#     primary_hub_name                                   = "vwan-hub-$${starter_location_01}"
#     primary_sidecar_virtual_network_name               = "vnet-sidecar-$${starter_location_01}"
#     primary_firewall_name                              = "fw-hub-$${starter_location_01}"
#     primary_firewall_policy_name                       = "fwp-hub-$${starter_location_01}"
#     primary_virtual_network_gateway_express_route_name = "vgw-hub-er-$${starter_location_01}"
#     primary_virtual_network_gateway_vpn_name           = "vgw-hub-vpn-$${starter_location_01}"
#     primary_private_dns_resolver_name                  = "pdr-hub-dns-$${starter_location_01}"
#     primary_bastion_host_name                          = "bas-hub-$${starter_location_01}"
#     primary_bastion_host_public_ip_name                = "pip-bastion-hub-$${starter_location_01}"

#     # Resource names secondary connectivity
#     secondary_hub_name                                   = "vwan-hub-$${starter_location_02}"
#     secondary_sidecar_virtual_network_name               = "vnet-sidecar-$${starter_location_02}"
#     secondary_firewall_name                              = "fw-hub-$${starter_location_02}"
#     secondary_firewall_policy_name                       = "fwp-hub-$${starter_location_02}"
#     secondary_virtual_network_gateway_express_route_name = "vgw-hub-er-$${starter_location_02}"
#     secondary_virtual_network_gateway_vpn_name           = "vgw-hub-vpn-$${starter_location_02}"
#     secondary_private_dns_resolver_name                  = "pdr-hub-dns-$${starter_location_02}"
#     secondary_bastion_host_name                          = "bas-hub-$${starter_location_02}"
#     secondary_bastion_host_public_ip_name                = "pip-bastion-hub-$${starter_location_02}"

#     # Private DNS Zones primary
#     primary_auto_registration_zone_name = "$${starter_location_01}.azure.local"

#     # Private DNS Zones secondary
#     secondary_auto_registration_zone_name = "$${starter_location_02}.azure.local"

#     # IP Ranges Primary
#     # Regional Address Space: 10.0.0.0/16
#     primary_hub_address_space                          = "10.0.0.0/22"
#     primary_sidecar_virtual_network_address_space      = "10.0.4.0/22"
#     primary_bastion_subnet_address_prefix              = "10.0.4.0/26"
#     primary_private_dns_resolver_subnet_address_prefix = "10.0.4.64/28"

#     # IP Ranges Secondary
#     # Regional Address Space: 10.1.0.0/16
#     secondary_hub_address_space                          = "10.1.0.0/22"
#     secondary_sidecar_virtual_network_address_space      = "10.1.4.0/22"
#     secondary_bastion_subnet_address_prefix              = "10.1.4.0/26"
#     secondary_private_dns_resolver_subnet_address_prefix = "10.1.4.64/28"
#   }

#   /*
#   --- Custom Resource Group Identifier Replacements ---
#   You can define custom resource group identifiers to use throughout the configuration.
#   You can only use the templated variables and custom names in this section.
#   NOTE: You cannot refer to another custom resource group identifier in this variable.
#   */
#   resource_group_identifiers = {
#     management_resource_group_id             = "/subscriptions/$${subscription_id_management}/resourcegroups/$${management_resource_group_name}"
#     ddos_protection_plan_resource_group_id   = "/subscriptions/$${subscription_id_connectivity}/resourcegroups/$${ddos_resource_group_name}"
#     primary_connectivity_resource_group_id   = "/subscriptions/$${subscription_id_connectivity}/resourceGroups/$${connectivity_hub_primary_resource_group_name}"
#     secondary_connectivity_resource_group_id = "/subscriptions/$${subscription_id_connectivity}/resourceGroups/$${connectivity_hub_secondary_resource_group_name}"
#     dns_resource_group_id                    = "/subscriptions/$${subscription_id_connectivity}/resourceGroups/$${dns_resource_group_name}"
#   }

#   /*
#   --- Custom Resource Identifier Replacements ---
#   You can define custom resource identifiers to use throughout the configuration.
#   You can only use the templated variables, custom names and customer resource group identifiers in this variable.
#   NOTE: You cannot refer to another custom resource identifier in this variable.
#   */
#   resource_identifiers = {
#     ama_change_tracking_data_collection_rule_id = "$${management_resource_group_id}/providers/Microsoft.Insights/dataCollectionRules/$${dcr_change_tracking_name}"
#     ama_mdfc_sql_data_collection_rule_id        = "$${management_resource_group_id}/providers/Microsoft.Insights/dataCollectionRules/$${dcr_defender_sql_name}"
#     ama_vm_insights_data_collection_rule_id     = "$${management_resource_group_id}/providers/Microsoft.Insights/dataCollectionRules/$${dcr_vm_insights_name}"
#     ama_user_assigned_managed_identity_id       = "$${management_resource_group_id}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$${ama_user_assigned_managed_identity_name}"
#     log_analytics_workspace_id                  = "$${management_resource_group_id}/providers/Microsoft.OperationalInsights/workspaces/$${log_analytics_workspace_name}"
#     ddos_protection_plan_id                     = "$${ddos_protection_plan_resource_group_id}/providers/Microsoft.Network/ddosProtectionPlans/$${ddos_protection_plan_name}"
#   }
# }

# /*
# --- Tags ---
# This variable can be used to apply tags to all resources that support it. Some resources allow overriding these tags.
# */
# tags = {
#   deployed_by = "terraform"
#   source      = "Azure Landing Zones Accelerator"
# }





# root_parent_management_group_id = "BCGOV-MGD-LZ"
# subscription_id_connectivity = "6b779108-96a1-48cd-8c7a-804c5a924d44"
# subscription_id_identity = "561b8413-cd9f-4b91-8745-c5937d8b3a61"
# subscription_id_management = "7eaf8022-ff10-43bd-851b-54c11c0fb515"
# subscription_id_security = "af6fee0c-9967-44d0-86f9-4bd603ffa174"


# enable_telemetry = true
# telemetry_additional_content = {
#   deployed_by    = "alz-terraform-accelerator"
#   correlation_id = "00000000-0000-0000-0000-000000000000"
# }
