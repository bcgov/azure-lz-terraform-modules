# /*
# --- Connectivity - Virtual WAN ---
# You can use this section to customize the virtual wan networking that will be deployed.
# */
# connectivity_type = "virtual_wan"

# connectivity_resource_groups = {
#   ddos = {
#     name     = "$${ddos_resource_group_name}"
#     location = "$${starter_location_01}"
#     settings = {
#       enabled = "$${ddos_protection_plan_enabled}"
#     }
#   }
#   vwan = {
#     name     = "$${connectivity_hub_vwan_resource_group_name}"
#     location = "$${starter_location_01}"
#     settings = {
#       enabled = true
#     }
#   }
#   vwan_hub_primary = {
#     name     = "$${connectivity_hub_primary_resource_group_name}"
#     location = "$${starter_location_01}"
#     settings = {
#       enabled = true
#     }
#   }
#   vwan_hub_secondary = {
#     name     = "$${connectivity_hub_secondary_resource_group_name}"
#     location = "$${starter_location_02}"
#     settings = {
#       enabled = true
#     }
#   }
#   dns = {
#     name     = "$${dns_resource_group_name}"
#     location = "$${starter_location_01}"
#     settings = {
#       enabled = "$${primary_private_dns_zones_enabled}"
#     }
#   }
# }

# virtual_wan_settings = {
#   enabled_resources = {
#     ddos_protection_plan = "$${ddos_protection_plan_enabled}"
#   }
#   virtual_wan = {
#     name                = "vwan-$${starter_location_01}"
#     resource_group_name = "$${connectivity_hub_vwan_resource_group_name}"
#     location            = "$${starter_location_01}"
#   }
#   ddos_protection_plan = {
#     name                = "$${ddos_protection_plan_name}"
#     resource_group_name = "$${ddos_resource_group_name}"
#     location            = "$${starter_location_01}"
#   }
# }

# virtual_hubs = {
#   primary = {
#     location = "$${starter_location_01}"
#     /*
#       NOTE: We are defaulting to a separate resource group for the hub per best practice for resiliency
#       However, there is a known limitation with the portal experience: https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-faq#can-hubs-be-created-in-different-resource-groups-in-virtual-wan
#       If you prefer to use the same resource group as the vwan, then set this to `$${connectivity_hub_vwan_resource_group_name}`
#     */
#     default_parent_id = "$${primary_connectivity_resource_group_id}"
#     enabled_resources = {
#       firewall                              = "$${primary_firewall_enabled}"
#       bastion                               = "$${primary_bastion_enabled}"
#       virtual_network_gateway_express_route = "$${primary_virtual_network_gateway_express_route_enabled}"
#       virtual_network_gateway_vpn           = "$${primary_virtual_network_gateway_vpn_enabled}"
#       private_dns_zones                     = "$${primary_private_dns_zones_enabled}"
#       private_dns_resolver                  = "$${primary_private_dns_resolver_enabled}"
#       sidecar_virtual_network               = "$${primary_sidecar_virtual_network_enabled}"
#     }
#     hub = {
#       name           = "$${primary_hub_name}"
#       address_prefix = "$${primary_hub_address_space}"
#     }
#     firewall = {
#       name     = "$${primary_firewall_name}"
#       sku_tier = "$${primary_firewall_sku_tier}"
#     }
#     firewall_policy = {
#       name = "$${primary_firewall_policy_name}"
#       sku  = "$${primary_firewall_sku_tier}"
#     }
#     virtual_network_gateways = {
#       express_route = {
#         name = "$${primary_virtual_network_gateway_express_route_name}"
#       }
#       vpn = {
#         name = "$${primary_virtual_network_gateway_vpn_name}"
#       }
#     }
#     private_dns_zones = {
#       parent_id = "$${dns_resource_group_id}"
#       private_link_private_dns_zones_regex_filter = {
#         enabled = false
#       }
#       auto_registration_zone_enabled = "$${primary_private_dns_auto_registration_zone_enabled}"
#       auto_registration_zone_name    = "$${primary_auto_registration_zone_name}"
#     }
#     private_dns_resolver = {
#       subnet_address_prefix = "$${primary_private_dns_resolver_subnet_address_prefix}"
#       name                  = "$${primary_private_dns_resolver_name}"
#     }
#     bastion = {
#       subnet_address_prefix = "$${primary_bastion_subnet_address_prefix}"
#       name                  = "$${primary_bastion_host_name}"
#       bastion_public_ip = {
#         name = "$${primary_bastion_host_public_ip_name}"
#       }
#     }
#     sidecar_virtual_network = {
#       name          = "$${primary_sidecar_virtual_network_name}"
#       address_space = ["$${primary_sidecar_virtual_network_address_space}"]
#       /*
#       virtual_network_connection_settings = {
#         name = "private_dns_vnet_primary"  # Backwards compatibility
#       }
#       */
#     }
#   }
#   secondary = {
#     location = "$${starter_location_02}"
#     /*
#       NOTE: We are defaulting to a separate resource group for the hub per best practice for resiliency
#       However, there is a known limitation with the portal experience: https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-faq#can-hubs-be-created-in-different-resource-groups-in-virtual-wan
#       If you prefer to use the same resource group as the vwan, then set this to `$${connectivity_hub_vwan_resource_group_name}`
#     */
#     default_parent_id = "$${secondary_connectivity_resource_group_id}"
#     enabled_resources = {
#       firewall                              = "$${secondary_firewall_enabled}"
#       bastion                               = "$${secondary_bastion_enabled}"
#       virtual_network_gateway_express_route = "$${secondary_virtual_network_gateway_express_route_enabled}"
#       virtual_network_gateway_vpn           = "$${secondary_virtual_network_gateway_vpn_enabled}"
#       private_dns_zones                     = "$${secondary_private_dns_zones_enabled}"
#       private_dns_resolver                  = "$${secondary_private_dns_resolver_enabled}"
#       sidecar_virtual_network               = "$${secondary_sidecar_virtual_network_enabled}"
#     }
#     hub = {
#       name           = "$${secondary_hub_name}"
#       address_prefix = "$${secondary_hub_address_space}"
#     }
#     firewall = {
#       name     = "$${secondary_firewall_name}"
#       sku_tier = "$${secondary_firewall_sku_tier}"
#     }
#     firewall_policy = {
#       name = "$${secondary_firewall_policy_name}"
#       sku  = "$${secondary_firewall_sku_tier}"
#     }
#     virtual_network_gateways = {
#       express_route = {
#         name = "$${secondary_virtual_network_gateway_express_route_name}"
#       }
#       vpn = {
#         name = "$${secondary_virtual_network_gateway_vpn_name}"
#       }
#     }
#     private_dns_zones = {
#       parent_id = "$${dns_resource_group_id}"
#       private_link_private_dns_zones_regex_filter = {
#         enabled = true
#       }
#       auto_registration_zone_enabled = "$${secondary_private_dns_auto_registration_zone_enabled}"
#       auto_registration_zone_name    = "$${secondary_auto_registration_zone_name}"
#     }
#     private_dns_resolver = {
#       subnet_address_prefix = "$${secondary_private_dns_resolver_subnet_address_prefix}"
#       name                  = "$${secondary_private_dns_resolver_name}"
#     }
#     bastion = {
#       subnet_address_prefix = "$${secondary_bastion_subnet_address_prefix}"
#       name                  = "$${secondary_bastion_host_name}"
#       bastion_public_ip = {
#         name = "$${secondary_bastion_host_public_ip_name}"
#       }
#     }
#     sidecar_virtual_network = {
#       name          = "$${secondary_sidecar_virtual_network_name}"
#       address_space = ["$${secondary_sidecar_virtual_network_address_space}"]
#       /*
#       virtual_network_connection_settings = {
#         name = "private_dns_vnet_secondary"  # Backwards compatibility
#       }
#       */
#     }
#   }
# }

# # private_link_private_dns_zone_virtual_network_link_moved_blocks_enabled = true
