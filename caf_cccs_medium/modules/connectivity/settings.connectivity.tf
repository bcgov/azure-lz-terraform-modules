# Configure custom connectivity resources settings
locals {
  configure_connectivity_resources = {
    settings = {
      # Do not create any hub networks
      hub_networks = []
      # Create a Virtual WAN resources
      vwan_hub_networks = [
        {
          enabled = true
          config = {
            address_prefix = var.vwan_hub_address_prefix
            location       = var.primary_location
            sku            = ""
            routes         = []
            routing_intent = {
              enabled = true
              config = {
                routing_policies = [
                  {
                    name = "InternetTrafficPolicy"
                    destinations = [
                      "Internet"
                    ]
                    next_hop = "${var.root_id}-fw-hub-${lower(var.primary_location)}" # NOTE: Unsure if we can reference the Azure Firewall that is also deployed as part of the CAF at the same time (ie. this.azure_firewall.id); Else we may have to double-deploy (ie. first-pass to get the vWAN and Firewall deployed, then second-pass to update to reference the Firewall name)
                  },
                  {
                    name = "PrivateTrafficPolicy"
                    destinations = [
                      "PrivateTraffic"
                    ]
                    next_hop = "${var.root_id}-fw-hub-${lower(var.primary_location)}"
                  }
                ]
              }
            }
            expressroute_gateway = {
              enabled = false
              config = {
                scale_unit = 1
              }
            }
            vpn_gateway = {
              enabled = false
              config = {
                bgp_settings       = []
                routing_preference = ""
                scale_unit         = 1
              }
            }
            azure_firewall = {
              enabled = true
              config = {
                # NOTE: Configuration of DNS proxy, DNS servers, Insights (ie. Policy Analytics), etc.
                # is handled in the custom firewall policy objects, and does not need to be defined here.
                # All that is required is to pass the firewall_policy_id via the advanced.custom_settings_by_resource_type.azurerm_firewall.virtual_wan.${lower(var.primary_location)} setting.
                # NOTE: This firewall_policy_id is the "child" policy, and is already associated with the "parent" policy.
                # Therefore, we do not need to associate the "parent" policy here.
                sku_tier = "Premium"
                availability_zones = {
                  zone_1 = true
                  zone_2 = true
                  zone_3 = true
                }
              }
            }
            spoke_virtual_network_resource_ids        = []
            secure_spoke_virtual_network_resource_ids = []
            enable_virtual_hub_connections            = false
          }
        },
        # {
        #   enabled = true
        #   config = {
        #     address_prefix = "10.201.0.0/22"
        #     location       = var.secondary_location
        #     sku            = ""
        #     routes         = []
        #     routing_intent = {
        #       enabled = false
        #       config = {
        #         routing_policies = []
        #       }
        #     }
        #     expressroute_gateway = {
        #       enabled = false
        #       config = {
        #         scale_unit = 1
        #       }
        #     }
        #     vpn_gateway = {
        #       enabled = false
        #       config = {
        #         bgp_settings       = []
        #         routing_preference = ""
        #         scale_unit         = 1
        #       }
        #     }
        #     azure_firewall = {
        #       enabled = true
        #       config = {
        #         enable_dns_proxy              = true
        #         dns_servers                   = []
        #         sku_tier                      = "Standard"
        #         base_policy_id                = ""
        #         private_ip_ranges             = []
        #         threat_intelligence_mode      = ""
        #         threat_intelligence_allowlist = []
        #         availability_zones = {
        #           zone_1 = true
        #           zone_2 = true
        #           zone_3 = true
        #         }
        #       }
        #     }
        #     spoke_virtual_network_resource_ids        = []
        #     secure_spoke_virtual_network_resource_ids = []
        #     enable_virtual_hub_connections            = false
        #   }
        # },
      ]
      # Enable DDoS protection plan in the primary location
      ddos_protection_plan = {
        enabled = var.enable_ddos_protection
        config = {
          location = var.primary_location
        }
      }
      # DNS will be deployed with default settings
      dns = {
        enabled = true
        config = {
          location = var.primary_location
          enable_private_link_by_service = {
            azure_api_management                 = true
            azure_app_configuration_stores       = true
            azure_arc                            = true
            azure_automation_dscandhybridworker  = true
            azure_automation_webhook             = true
            azure_backup                         = true
            azure_batch_account                  = true
            azure_bot_service_bot                = true
            azure_bot_service_token              = true
            azure_cache_for_redis                = true
            azure_cache_for_redis_enterprise     = true
            azure_container_registry             = true
            azure_cosmos_db_cassandra            = true
            azure_cosmos_db_gremlin              = true
            azure_cosmos_db_mongodb              = true
            azure_cosmos_db_sql                  = true
            azure_cosmos_db_table                = true
            azure_data_explorer                  = true
            azure_data_factory                   = true
            azure_data_factory_portal            = true
            azure_data_health_data_services      = true
            azure_data_lake_file_system_gen2     = true
            azure_database_for_mariadb_server    = true
            azure_database_for_mysql_server      = true
            azure_database_for_postgresql_server = true
            azure_digital_twins                  = true
            azure_event_grid_domain              = true
            azure_event_grid_topic               = true
            azure_event_hubs_namespace           = true
            azure_file_sync                      = true
            azure_hdinsights                     = true
            azure_iot_dps                        = true
            azure_iot_hub                        = true
            azure_key_vault                      = true
            azure_key_vault_managed_hsm          = true
            azure_kubernetes_service_management  = true
            azure_machine_learning_workspace     = true
            azure_managed_disks                  = true
            azure_media_services                 = true
            azure_migrate                        = true
            azure_monitor                        = true
            azure_purview_account                = true
            azure_purview_studio                 = true
            azure_relay_namespace                = true
            azure_search_service                 = true
            azure_service_bus_namespace          = true
            azure_site_recovery                  = true
            azure_sql_database_sqlserver         = true
            azure_synapse_analytics_dev          = true
            azure_synapse_analytics_sql          = true
            azure_synapse_studio                 = true
            azure_web_apps_sites                 = true
            azure_web_apps_static_sites          = true
            cognitive_services_account           = true
            microsoft_power_bi                   = true
            signalr                              = true
            signalr_webpubsub                    = true
            storage_account_blob                 = true
            storage_account_file                 = true
            storage_account_queue                = true
            storage_account_table                = true
            storage_account_web                  = true
          }
          private_link_locations = [
            var.primary_location,
            var.secondary_location,
          ]
          public_dns_zones                                       = []
          private_dns_zones                                      = []
          enable_private_dns_zone_virtual_network_link_on_hubs   = true
          enable_private_dns_zone_virtual_network_link_on_spokes = true
          virtual_network_resource_ids_to_link = [
            "/subscriptions/${var.subscription_id_connectivity}/resourceGroups/${var.root_id}-privatedns-connectivity/providers/Microsoft.Network/virtualNetworks/${var.root_id}-privatedns-spoke"
          ]
        }
      }
    }
    # Set the default location
    location = var.primary_location
    # Create a custom tags input
    tags = var.connectivity_resources_tags

    advanced = {
      custom_settings_by_resource_type = {
        azurerm_firewall = {
          virtual_wan = {
            "${lower(var.primary_location)}" = {
              firewall_policy_id = var.firewall_child_policy_id
            }
          }
        }
      }
    }
  }
}
