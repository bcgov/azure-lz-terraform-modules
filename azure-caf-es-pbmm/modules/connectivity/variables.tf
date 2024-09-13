# Use variables to customize the deployment

variable "root_parent_id" {
  type        = string
  description = "Sets the value for the parent management group."
}

variable "root_id" {
  type        = string
  description = "Sets the value used for generating unique resource naming within the module."
}

variable "primary_location" {
  type        = string
  description = "Sets the location for \"primary\" resources to be created in."
}

variable "secondary_location" {
  type        = string
  description = "Sets the location for \"secondary\" resources to be created in."
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "enable_ddos_protection" {
  type        = bool
  description = "Controls whether to create a DDoS Network Protection plan and link to hub virtual networks."
}

variable "connectivity_resources_tags" {
  type        = map(string)
  description = "Specify tags to add to \"connectivity\" resources."
}

variable "configure_connectivity_resources" {
  type = object({
    settings = optional(object({
      hub_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_space                = list(string)
            location                     = optional(string, "")
            link_to_ddos_protection_plan = optional(bool, false)
            dns_servers                  = optional(list(string), [])
            bgp_community                = optional(string, "")
            subnets = optional(list(
              object({
                name                      = string
                address_prefixes          = list(string)
                network_security_group_id = optional(string, "")
                route_table_id            = optional(string, "")
              })
            ), [])
            virtual_network_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                address_prefix              = optional(string, "")
                gateway_sku_expressroute    = optional(string, "")
                gateway_sku_vpn             = optional(string, "")
                remote_vnet_traffic_enabled = optional(bool, false)
                virtual_wan_traffic_enabled = optional(bool, false)
                advanced_vpn_settings = optional(object({
                  enable_bgp                       = optional(bool, null)
                  active_active                    = optional(bool, null)
                  private_ip_address_allocation    = optional(string, "")
                  default_local_network_gateway_id = optional(string, "")
                  vpn_client_configuration = optional(list(
                    object({
                      address_space = list(string)
                      aad_tenant    = optional(string, null)
                      aad_audience  = optional(string, null)
                      aad_issuer    = optional(string, null)
                      root_certificate = optional(list(
                        object({
                          name             = string
                          public_cert_data = string
                        })
                      ), [])
                      revoked_certificate = optional(list(
                        object({
                          name       = string
                          thumbprint = string
                        })
                      ), [])
                      radius_server_address = optional(string, null)
                      radius_server_secret  = optional(string, null)
                      vpn_client_protocols  = optional(list(string), null)
                      vpn_auth_types        = optional(list(string), null)
                    })
                  ), [])
                  bgp_settings = optional(list(
                    object({
                      asn         = optional(number, null)
                      peer_weight = optional(number, null)
                      peering_addresses = optional(list(
                        object({
                          ip_configuration_name = optional(string, null)
                          apipa_addresses       = optional(list(string), null)
                        })
                      ), [])
                    })
                  ), [])
                  custom_route = optional(list(
                    object({
                      address_prefixes = optional(list(string), [])
                    })
                  ), [])
                }), {})
              }), {})
            }), {})
            azure_firewall = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                address_prefix                = optional(string, "")
                address_management_prefix     = optional(string, "")
                enable_dns_proxy              = optional(bool, true)
                dns_servers                   = optional(list(string), [])
                sku_tier                      = optional(string, "Standard")
                base_policy_id                = optional(string, "")
                private_ip_ranges             = optional(list(string), [])
                threat_intelligence_mode      = optional(string, "Alert")
                threat_intelligence_allowlist = optional(map(list(string)), {})
                availability_zones = optional(object({
                  zone_1 = optional(bool, true)
                  zone_2 = optional(bool, true)
                  zone_3 = optional(bool, true)
                }), {})
              }), {})
            }), {})
            spoke_virtual_network_resource_ids      = optional(list(string), [])
            enable_outbound_virtual_network_peering = optional(bool, false)
            enable_hub_network_mesh_peering         = optional(bool, false)
          })
        })
      ), [])
      vwan_hub_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_prefix = string
            location       = string
            sku            = optional(string, "")
            routes = optional(list(
              object({
                address_prefixes    = list(string)
                next_hop_ip_address = string
              })
            ), [])
            routing_intent = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                routing_policies = optional(list(object({
                  name         = string
                  destinations = list(string)
                })), [])
              }), {})
            }), {})
            expressroute_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                scale_unit                    = optional(number, 1)
                allow_non_virtual_wan_traffic = optional(bool, false)
              }), {})
            }), {})
            vpn_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                bgp_settings = optional(list(
                  object({
                    asn         = number
                    peer_weight = number
                    instance_0_bgp_peering_address = optional(list(
                      object({
                        custom_ips = list(string)
                      })
                    ), [])
                    instance_1_bgp_peering_address = optional(list(
                      object({
                        custom_ips = list(string)
                      })
                    ), [])
                  })
                ), [])
                routing_preference = optional(string, "Microsoft Network")
                scale_unit         = optional(number, 1)
              }), {})
            }), {})
            azure_firewall = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                enable_dns_proxy              = optional(bool, true)
                dns_servers                   = optional(list(string), [])
                sku_tier                      = optional(string, "Standard")
                base_policy_id                = optional(string, "")
                private_ip_ranges             = optional(list(string), [])
                threat_intelligence_mode      = optional(string, "Alert")
                threat_intelligence_allowlist = optional(map(list(string)), {})
                availability_zones = optional(object({
                  zone_1 = optional(bool, true)
                  zone_2 = optional(bool, true)
                  zone_3 = optional(bool, true)
                }), {})
              }), {})
            }), {})
            spoke_virtual_network_resource_ids        = optional(list(string), [])
            secure_spoke_virtual_network_resource_ids = optional(list(string), [])
            enable_virtual_hub_connections            = optional(bool, false)
          })
        })
      ), [])
      ddos_protection_plan = optional(object({
        enabled = optional(bool, false)
        config = optional(object({
          location = optional(string, "")
        }), {})
      }), {})
      dns = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          location = optional(string, "")
          enable_private_link_by_service = optional(object({
            azure_api_management                 = optional(bool, true)
            azure_app_configuration_stores       = optional(bool, true)
            azure_arc                            = optional(bool, true)
            azure_arc_guest_configuration        = optional(bool, true)
            azure_arc_hybrid_resource_provider   = optional(bool, true)
            azure_arc_kubernetes                 = optional(bool, true)
            azure_automation_dscandhybridworker  = optional(bool, true)
            azure_automation_webhook             = optional(bool, true)
            azure_backup                         = optional(bool, true)
            azure_batch_account                  = optional(bool, true)
            azure_bot_service_bot                = optional(bool, true)
            azure_bot_service_token              = optional(bool, true)
            azure_cache_for_redis                = optional(bool, true)
            azure_cache_for_redis_enterprise     = optional(bool, true)
            azure_container_registry             = optional(bool, true)
            azure_cosmos_db_cassandra            = optional(bool, true)
            azure_cosmos_db_gremlin              = optional(bool, true)
            azure_cosmos_db_mongodb              = optional(bool, true)
            azure_cosmos_db_sql                  = optional(bool, true)
            azure_cosmos_db_table                = optional(bool, true)
            azure_data_explorer                  = optional(bool, true)
            azure_data_factory                   = optional(bool, true)
            azure_data_factory_portal            = optional(bool, true)
            azure_data_health_data_services      = optional(bool, true)
            azure_data_lake_file_system_gen2     = optional(bool, true)
            azure_database_for_mariadb_server    = optional(bool, true)
            azure_database_for_mysql_server      = optional(bool, true)
            azure_database_for_postgresql_server = optional(bool, true)
            azure_databricks                     = optional(bool, true)
            azure_digital_twins                  = optional(bool, true)
            azure_event_grid_domain              = optional(bool, true)
            azure_event_grid_topic               = optional(bool, true)
            azure_event_hubs_namespace           = optional(bool, true)
            azure_file_sync                      = optional(bool, true)
            azure_hdinsights                     = optional(bool, true)
            azure_iot_dps                        = optional(bool, true)
            azure_iot_hub                        = optional(bool, true)
            azure_key_vault                      = optional(bool, true)
            azure_key_vault_managed_hsm          = optional(bool, true)
            azure_kubernetes_service_management  = optional(bool, true)
            azure_machine_learning_workspace     = optional(bool, true)
            azure_managed_disks                  = optional(bool, true)
            azure_managed_grafana                = optional(bool, true)
            azure_media_services                 = optional(bool, true)
            azure_migrate                        = optional(bool, true)
            azure_monitor                        = optional(bool, true)
            azure_openai_service                 = optional(bool, true)
            azure_purview_account                = optional(bool, true)
            azure_purview_studio                 = optional(bool, true)
            azure_relay_namespace                = optional(bool, true)
            azure_search_service                 = optional(bool, true)
            azure_service_bus_namespace          = optional(bool, true)
            azure_site_recovery                  = optional(bool, true)
            azure_sql_database_sqlserver         = optional(bool, true)
            azure_synapse_analytics_dev          = optional(bool, true)
            azure_synapse_analytics_sql          = optional(bool, true)
            azure_synapse_studio                 = optional(bool, true)
            azure_virtual_desktop                = optional(bool, true)
            azure_web_apps_sites                 = optional(bool, true)
            azure_web_apps_static_sites          = optional(bool, true)
            cognitive_services_account           = optional(bool, true)
            microsoft_power_bi                   = optional(bool, true)
            signalr                              = optional(bool, true)
            signalr_webpubsub                    = optional(bool, true)
            storage_account_blob                 = optional(bool, true)
            storage_account_file                 = optional(bool, true)
            storage_account_queue                = optional(bool, true)
            storage_account_table                = optional(bool, true)
            storage_account_web                  = optional(bool, true)
          }), {})
          private_link_locations                                 = optional(list(string), [])
          public_dns_zones                                       = optional(list(string), [])
          private_dns_zones                                      = optional(list(string), [])
          enable_private_dns_zone_virtual_network_link_on_hubs   = optional(bool, true)
          enable_private_dns_zone_virtual_network_link_on_spokes = optional(bool, true)
          virtual_network_resource_ids_to_link                   = optional(list(string), [])
        }), {})
      }), {})
    }), {})
    location = optional(string, "")
    tags     = optional(any, {})
    advanced = optional(any, {})
  })
  description = <<DESCRIPTION
If specified, will customize the \"Connectivity\" landing zone settings and resources.

Notes for the `configure_connectivity_resources` variable:

- `settings.hub_network_virtual_network_gateway.config.address_prefix`
  - Only support adding a single address prefix for GatewaySubnet subnet
- `settings.hub_network_virtual_network_gateway.config.gateway_sku_expressroute`
  - If specified, will deploy the ExpressRoute gateway into the GatewaySubnet subnet
- `settings.hub_network_virtual_network_gateway.config.gateway_sku_vpn`
  - If specified, will deploy the VPN gateway into the GatewaySubnet subnet
- `settings.hub_network_virtual_network_gateway.config.advanced_vpn_settings.private_ip_address_allocation`
  - Valid options are `""`, `"Static"` or `"Dynamic"`. Will set `private_ip_address_enabled` and `private_ip_address_allocation` as needed.
- `settings.azure_firewall.config.address_prefix`
  - Only support adding a single address prefix for AzureFirewallManagementSubnet subnet
DESCRIPTION
  default     = {}
}
