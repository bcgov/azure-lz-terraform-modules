data "azapi_client_config" "current" {}

locals {
  parent_resource_id = var.parent_resource_id != "" ? var.parent_resource_id : data.azapi_client_config.current.tenant_id

  management_log_analytics_workspace_id = try(
    module.management_resources.log_analytics_workspace_resource_id,
    module.management_resources.azurerm_log_analytics_workspace,
    null
  )

  management_group_names = {
    root         = var.management_group_names.root
    platform     = var.management_group_names.platform
    management   = var.management_group_names.management
    connectivity = var.management_group_names.connectivity
    identity     = var.management_group_names.identity
    security     = var.management_group_names.security
    landingzones = var.management_group_names.landingzones
  }

  subscription_placement = {
    management = {
      subscription_id       = var.subscription_ids.management
      management_group_name = local.management_group_names.management
    }
    connectivity = {
      subscription_id       = var.subscription_ids.connectivity
      management_group_name = local.management_group_names.connectivity
    }
    identity = {
      subscription_id       = var.subscription_ids.identity
      management_group_name = local.management_group_names.identity
    }
    security = {
      subscription_id       = var.subscription_ids.security
      management_group_name = local.management_group_names.security
    }
  }

  firewall_policy_centralized_logging_defaults = var.enable_centralized_logging && local.management_log_analytics_workspace_id != null ? {
    insights = {
      enabled                            = true
      default_log_analytics_workspace_id = local.management_log_analytics_workspace_id
    }
  } : {}

  firewall_policy_external_base_policy_defaults = var.external_base_firewall_policy_id != null ? {
    base_policy_id = var.external_base_firewall_policy_id
  } : {}

  private_dns_zone_defaults_by_hub = {
    for hub_name, _ in var.virtual_hubs : hub_name => merge(
      var.private_dns_enable_internet_fallback ? {
        virtual_network_link_resolution_policy_default = "NxDomainRedirect"
      } : {},
      contains(keys(var.private_dns_resolver_virtual_network_resource_id_by_hub), hub_name) ? {
        virtual_network_link_default_virtual_networks = {
          resolver = merge(
            {
              virtual_network_resource_id = var.private_dns_resolver_virtual_network_resource_id_by_hub[hub_name]
            },
            var.private_dns_enable_internet_fallback ? {
              resolution_policy = "NxDomainRedirect"
            } : {}
          )
        }
      } : {}
    )
  }

  effective_virtual_hubs = {
    for hub_name, hub_config in var.virtual_hubs : hub_name => merge(
      hub_config,
      {
        enabled_resources = merge(
          try(hub_config.enabled_resources, {}),
          {
            virtual_network_gateway_express_route = var.enable_express_route
            virtual_network_gateway_vpn           = var.enable_s2s_vpn
          }
        )
      },
      {
        firewall_policy = merge(
          local.firewall_policy_centralized_logging_defaults,
          try(hub_config.firewall_policy, {}),
          local.firewall_policy_external_base_policy_defaults
        )
      },
      {
        private_dns_zones = merge(
          try(hub_config.private_dns_zones, {}),
          try(local.private_dns_zone_defaults_by_hub[hub_name], {}),
          contains(keys(var.private_dns_zones_by_hub), hub_name) ? var.private_dns_zones_by_hub[hub_name] : {}
        )
      },
      contains(keys(var.express_route_circuit_connections_by_hub), hub_name) ? {
        express_route_circuit_connections = var.express_route_circuit_connections_by_hub[hub_name]
      } : {},
      contains(keys(var.vpn_sites_by_hub), hub_name) ? {
        vpn_sites = var.vpn_sites_by_hub[hub_name]
      } : {},
      contains(keys(var.vpn_site_connections_by_hub), hub_name) ? {
        vpn_site_connections = var.vpn_site_connections_by_hub[hub_name]
      } : {},
      contains(keys(var.routing_intents_by_hub), hub_name) ? {
        routing_intents = var.routing_intents_by_hub[hub_name]
      } : {},
      contains(keys(var.private_dns_resolver_by_hub), hub_name) ? {
        private_dns_resolver = var.private_dns_resolver_by_hub[hub_name]
      } : {}
    )
  }

  amba_policy_defaults = var.enable_amba ? {
    amba_alz_management_subscription_id            = jsonencode({ value = var.subscription_ids.management })
    amba_alz_resource_group_location               = jsonencode({ value = var.primary_location })
    amba_alz_resource_group_name                   = jsonencode({ value = var.amba_resource_group_name })
    amba_alz_resource_group_tags                   = jsonencode({ value = var.tags })
    amba_alz_user_assigned_managed_identity_name   = jsonencode({ value = var.amba_user_assigned_managed_identity_name })
    amba_alz_byo_user_assigned_managed_identity_id = jsonencode({ value = "" })
    amba_alz_disable_tag_name                      = jsonencode({ value = "MonitorDisable" })
    amba_alz_disable_tag_values                    = jsonencode({ value = ["true", "Test", "Dev", "Sandbox"] })
    amba_alz_action_group_email                    = jsonencode({ value = [] })
    amba_alz_arm_role_id                           = jsonencode({ value = [] })
    amba_alz_webhook_service_uri                   = jsonencode({ value = [] })
    amba_alz_event_hub_resource_id                 = jsonencode({ value = [] })
    amba_alz_function_resource_id                  = jsonencode({ value = "" })
    amba_alz_function_trigger_url                  = jsonencode({ value = "" })
    amba_alz_logicapp_resource_id                  = jsonencode({ value = "" })
    amba_alz_logicapp_callback_url                 = jsonencode({ value = "" })
    amba_alz_byo_alert_processing_rule             = jsonencode({ value = "" })
    amba_alz_byo_action_group                      = jsonencode({ value = [] })
  } : {}

  effective_policy_default_values = merge(local.amba_policy_defaults, var.policy_default_values)
}
