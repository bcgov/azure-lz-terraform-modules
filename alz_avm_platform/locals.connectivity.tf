locals {
  vwan_resource_group_name = "bcgov-managed-lz-avm-connectivity"

  virtual_wan_settings = {
    enabled_resources = {
      ddos_protection_plan = false
    }
    virtual_wan = {
      name                              = "bcgov-managed-lz-avm-vwan-canadacentral" # TODO: Do we want a locals for location patterns (ie. lowercase, no spaces, etc.)?
      resource_group_name               = "bcgov-managed-lz-avm-connectivity"
      location                          = "canadacentral"
      type                              = "Standard"
      allow_branch_to_branch_traffic    = true
      disable_vpn_encryption            = false
      office365_local_breakout_category = "None"
    }
  }

  virtual_hubs = {
    primary = {
      location = "canadacentral"
      /*
        NOTE: We are defaulting to a separate resource group for the hub per best practice for resiliency
        However, there is a known limitation with the portal experience: https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-faq#can-hubs-be-created-in-different-resource-groups-in-virtual-wan
        If you prefer to use the same resource group as the vwan, then set this to `$${connectivity_hub_vwan_resource_group_name}`
      */
      default_parent_id = "/subscriptions/6b779108-96a1-48cd-8c7a-804c5a924d44/resourceGroups/bcgov-managed-lz-avm-connectivity"
      enabled_resources = {
        firewall                              = true
        bastion                               = false
        virtual_network_gateway_express_route = true
        virtual_network_gateway_vpn           = true
        private_dns_zones                     = true
        private_dns_resolver                  = true
        sidecar_virtual_network               = true
      }
      hub = {
        name                   = "bcgov-managed-lz-avm-hub-canadacentral"
        address_prefix         = "10.41.252.0/22"
        hub_routing_preference = "VpnGateway" # Default: ExpressRoute
      }
      routing_intents = { # NOTE: Requires the firewall to be deployed
        primary = {
          name = "avm-routing-intent-name"
          routing_policies = [
            {
              name = "InternetTrafficPolicy"
              destinations = [
                "Internet"
              ]
              next_hop_firewall_key = "primary" # NOTE: This must match the virtual_hubs map key, not the firewall name/ID
            },
            {
              name = "PrivateTrafficPolicy"
              destinations = [
                "PrivateTraffic"
              ]
              next_hop_firewall_key = "primary" # NOTE: This must match the virtual_hubs map key, not the firewall name/ID
            }
          ]
        }
      }
      firewall = {
        name     = "bcgov-managed-lz-avm-fw-hub-canadacentral"
        sku_tier = "Premium"
        # Pin zones explicitly; zones is ForceNew and otherwise falls back to a live Azure Locations API lookup that
        # can resolve to (known after apply), forcing an unwanted firewall destroy/recreate on unrelated plans.
        zones = ["1", "2", "3"]
      }
      firewall_policy = {
        name                              = "avm_lz_firewall_policy"
        resource_group_name               = "bcgov-managed-lz-avm-fwpolicy-connectivity"
        sku                               = "Premium"
        auto_learn_private_ranges_enabled = false
        # base_policy_id = "" # NOTE: This is the parent firewall policy, which needs to pre-exist
        dns = {
          proxy_enabled = true
          servers = [
            "10.41.12.4"
          ]
        }
        insights = {
          enabled                            = true
          retention_in_days                  = 30
          default_log_analytics_workspace_id = "/subscriptions/7eaf8022-ff10-43bd-851b-54c11c0fb515/resourceGroups/bcgov-managed-lz-avm-mgmt/providers/Microsoft.OperationalInsights/workspaces/bcgov-managed-lz-avm-la" # NOTE: This is the log analytics workspace, which needs to pre-exist
        }
        intrusion_detection = { # IMPORTANT: This should be in the parent firewall policy.
          mode = "Alert"        # Possible values are Alert, Deny, Off.
          # signature_overrides = [
          #   {
          #     id = ""
          #     state = "Alert" # Possible values are Alert, Deny, Off.
          #   }
          # ]
          traffic_bypass = [
            {
              name        = "VPN-Tunnel-Endpoints"
              description = "Turn off deep-packet inspection for traffic between the VPN tunnel endpoints"
              protocol    = "Any"
              source_addresses = [
                "10.41.252.4",
                "10.41.252.5"
              ]
              source_ip_groups = []
              destination_addresses = [
                "192.168.0.1"
              ]
              destination_ip_groups = []
              destination_ports = [
                "*"
              ]
            },
            # {
            #   name = "GitHub-Managed-Runners-Private-VNET"
            #   description = "Turn off intrusion detection (IDPS) for Azure private networking for GitHub-hosted runners"
            #   protocol = "TCP"
            #   source_addresses = []
            #   source_ip_groups = [
            #     "/subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-ip-groups/providers/Microsoft.Network/ipGroups/GitHub-Runners-VNET"
            #   ]
            #   destination_addresses = []
            #   destination_ip_groups = [
            #     "/subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-ip-groups/providers/Microsoft.Network/ipGroups/GitHub-Actions-IP-Ranges",
            #                 "/subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-ip-groups/providers/Microsoft.Network/ipGroups/GitHub-Enterprise-IP-Ranges"
            #   ]
            #   destination_ports = [
            #     "*"
            #   ]
            # }
          ]
          private_ranges = []
        }
        # A list of private IP ranges to which traffic will not be SNAT.
        # NOTE: CAF deployment configured with locals and YAML file
        private_ip_ranges = concat(
          local.rfc_1918_address_ranges,
          local.onpremises_address_ranges
        )
        threat_intelligence_mode = "Alert" # Possible values are Alert, Deny, Off.
      }

      virtual_network_gateways = {
        express_route = {
          name = "bcgov-managed-lz-forge-ergw-canadacentral"
        }
        vpn = {
          name = "bcgov-managed-lz-forge-vpngw-canadacentral"
        }
      }

      private_dns_zones = {
        parent_id = "/subscriptions/6b779108-96a1-48cd-8c7a-804c5a924d44/resourceGroups/bcgov-managed-lz-avm-dns" # must exist prior to deployment
        private_link_private_dns_zones_regex_filter = {
          enabled = false
        }
        auto_registration_zone_enabled = false
        # NxDomainRedirect = fall back to internet (public DNS) resolution on NXDOMAIN from the private zone.
        virtual_network_link_resolution_policy_default = "NxDomainRedirect"
      }
      private_dns_resolver = {
        name                  = "bcgov-managed-lz-avm-private-dns-resolver"
        resource_group_name   = "bcgov-managed-lz-avm-privatedns-connectivity"
        subnet_name           = "inbound_endpoint"
        subnet_address_prefix = "10.41.12.0/24"
        # Disabled because we define our own named inbound endpoint below (avoids a duplicate default endpoint).
        default_inbound_endpoint_enabled = false
        inbound_endpoints = {
          inbound = {
            name = "bcgov-managed-lz-avm-private-dns-resolver-inbound-endpoint"
            # The module always creates a subnet named subnet_name/subnet_address_prefix above (regardless of
            # default_inbound_endpoint_enabled), so we reuse it here instead of defining a separate, redundant
            # "inbound_endpoint" subnet under sidecar_virtual_network.subnets.
            # LIMITATION: this auto-created subnet has no network_security_group option in this module version,
            # so the inbound endpoint's subnet cannot get its own NSG (unlike outbound_endpoint below).
            subnet_name                  = "inbound_endpoint"
            private_ip_allocation_method = "Dynamic"
          }
        }
        outbound_endpoints = {
          outbound = {
            name        = "bcgov-managed-lz-avm-private-dns-resolver-outbound-endpoint"
            subnet_name = "outbound_endpoint"
            # forwarding_ruleset is a MAP of rulesets (keyed arbitrarily), each with its own `rules` map.
            # A bare object here (without this ruleset-key level) makes the module treat "rules" as the
            # ruleset key, leaving `ruleset.rules` null and causing "Iteration over null value".
            forwarding_ruleset = {
              dns = {
                name = "bcgov-managed-lz-avm-private-dns-resolver-dns-forwarding-ruleset"
                rules = {
                  bcgov = {
                    name        = "bcgov"
                    domain_name = "bcgov."
                    enabled     = true
                    # destination_ip_addresses is keyed by IP address, value is the port
                    destination_ip_addresses = {
                      "142.34.50.52" = "53"
                      "142.34.208.8" = "53"
                    }
                  }
                }
              }
            }
          }
        }
      }
      # bastion = {
      #   subnet_address_prefix = "$${primary_bastion_subnet_address_prefix}"
      #   name                  = "$${primary_bastion_host_name}"
      #   bastion_public_ip = {
      #     name = "$${primary_bastion_host_public_ip_name}"
      #   }
      # }
      sidecar_virtual_network = {
        name          = "bcgov-managed-lz-avm-privatedns-spoke"
        parent_id     = "/subscriptions/6b779108-96a1-48cd-8c7a-804c5a924d44/resourceGroups/bcgov-managed-lz-avm-privatedns-connectivity"
        address_space = ["10.41.12.0/23"]
        # No "inbound_endpoint" subnet here: the private_dns_resolver block above already creates
        # "privatedns-subnet" (via subnet_name/subnet_address_prefix) and the inbound endpoint reuses it,
        # so defining a second inbound subnet here would just be an unused duplicate.
        subnets = {
          outbound_endpoint = {
            name             = "outbound_endpoint"
            address_prefixes = ["10.41.13.0/24"]
            delegations = [{
              name = "Microsoft.Network.dnsResolvers"
              service_delegation = {
                name = "Microsoft.Network/dnsResolvers"
              }
            }]
          }
        }
        # internet_security_enabled routes this vnet's internet-bound traffic through the hub's firewall,
        # per the InternetTrafficPolicy routing intent above.
        virtual_network_connection_settings = {
          name                      = "vhc-hub_to_privatedns-spoke" # Backwards compatibility
          internet_security_enabled = true
        }
      }
      # }
      # secondary = {
      #   location = "$${starter_location_02}"
      #   /*
      #     NOTE: We are defaulting to a separate resource group for the hub per best practice for resiliency
      #     However, there is a known limitation with the portal experience: https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-faq#can-hubs-be-created-in-different-resource-groups-in-virtual-wan
      #     If you prefer to use the same resource group as the vwan, then set this to `$${connectivity_hub_vwan_resource_group_name}`
      #   */
      #   default_parent_id = "$${secondary_connectivity_resource_group_id}"
      #   enabled_resources = {
      #     firewall                              = "$${secondary_firewall_enabled}"
      #     bastion                               = "$${secondary_bastion_enabled}"
      #     virtual_network_gateway_express_route = "$${secondary_virtual_network_gateway_express_route_enabled}"
      #     virtual_network_gateway_vpn           = "$${secondary_virtual_network_gateway_vpn_enabled}"
      #     private_dns_zones                     = "$${secondary_private_dns_zones_enabled}"
      #     private_dns_resolver                  = "$${secondary_private_dns_resolver_enabled}"
      #     sidecar_virtual_network               = "$${secondary_sidecar_virtual_network_enabled}"
      #   }
      #   hub = {
      #     name           = "$${secondary_hub_name}"
      #     address_prefix = "$${secondary_hub_address_space}"
      #   }
      #   firewall = {
      #     name     = "$${secondary_firewall_name}"
      #     sku_tier = "$${secondary_firewall_sku_tier}"
      #   }
      #   firewall_policy = {
      #     name = "$${secondary_firewall_policy_name}"
      #     sku  = "$${secondary_firewall_sku_tier}"
      #   }
      #   virtual_network_gateways = {
      #     express_route = {
      #       name = "$${secondary_virtual_network_gateway_express_route_name}"
      #     }
      #     vpn = {
      #       name = "$${secondary_virtual_network_gateway_vpn_name}"
      #     }
      #   }
      #   private_dns_zones = {
      #     parent_id = "$${dns_resource_group_id}"
      #     private_link_private_dns_zones_regex_filter = {
      #       enabled = true
      #     }
      #     auto_registration_zone_enabled = "$${secondary_private_dns_auto_registration_zone_enabled}"
      #     auto_registration_zone_name    = "$${secondary_auto_registration_zone_name}"
      #   }
      #   private_dns_resolver = {
      #     subnet_address_prefix = "$${secondary_private_dns_resolver_subnet_address_prefix}"
      #     name                  = "$${secondary_private_dns_resolver_name}"
      #   }
      #   bastion = {
      #     subnet_address_prefix = "$${secondary_bastion_subnet_address_prefix}"
      #     name                  = "$${secondary_bastion_host_name}"
      #     bastion_public_ip = {
      #       name = "$${secondary_bastion_host_public_ip_name}"
      #     }
      #   }
      #   sidecar_virtual_network = {
      #     name          = "$${secondary_sidecar_virtual_network_name}"
      #     address_space = ["$${secondary_sidecar_virtual_network_address_space}"]
      #     /*
      #     virtual_network_connection_settings = {
      #       name = "private_dns_vnet_secondary"  # Backwards compatibility
      #     }
      #     */
      #   }
    }
  }
}
