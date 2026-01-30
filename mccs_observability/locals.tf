locals {
  # Subscription ID handling with fallbacks
  subscription_id_connectivity = coalesce(var.subscription_id_connectivity, data.azurerm_client_config.current.subscription_id)
  subscription_id_management   = coalesce(var.subscription_id_management, data.azurerm_client_config.current.subscription_id)

  # Resource naming
  resource_prefix = "mccs-${var.environment}"
  resource_suffix = var.location == "canadacentral" ? "cc" : "ce"

  # Computed resource names with optional overrides
  resource_group_name          = coalesce(var.resource_group_name, "rg-${local.resource_prefix}-observability-${local.resource_suffix}")
  key_vault_name               = coalesce(var.key_vault_name, "kv-${local.resource_prefix}-${local.resource_suffix}")
  log_analytics_workspace_name = coalesce(var.log_analytics_workspace_name, "log-${local.resource_prefix}-${local.resource_suffix}")
  # Grafana name max 23 chars, so use short prefix (grf-mccs-prod-cc-xxxx = 20 chars)
  grafana_name           = coalesce(var.grafana_name, "grf-${local.resource_prefix}-${local.resource_suffix}")
  postgresql_server_name = coalesce(var.postgresql_server_name, "psql-${local.resource_prefix}-${local.resource_suffix}")
  storage_account_name   = coalesce(var.storage_account_name, "st${replace(local.resource_prefix, "-", "")}${local.resource_suffix}")
  action_group_name      = coalesce(var.action_group_name, "ag-${local.resource_prefix}-alerts")
  logic_app_name         = coalesce(var.logic_app_name, "logic-${local.resource_prefix}-alert-router")

  # Container instance names
  netbox_aci_name     = "aci-${local.resource_prefix}-netbox"
  prometheus_aci_name = "aci-${local.resource_prefix}-prometheus"

  # VNet name
  vnet_name = coalesce(var.vnet_name, "vnet-${local.resource_prefix}-${local.resource_suffix}")

  # Subnet names
  subnet_containers        = "snet-${local.resource_prefix}-containers"
  subnet_postgresql        = "snet-${local.resource_prefix}-postgresql"
  subnet_private_endpoints = "snet-${local.resource_prefix}-privateendpoints"

  # IPAM - Compute VNet address space and subnet CIDRs
  # When using IPAM, we allocate a /24 and split it into three /26 subnets
  # When not using IPAM, we use the static CIDR variable
  # Note: address_prefixes is always available after IPAM resource creation (depends_on ensures ordering)
  ipam_base_cidr = var.use_ipam ? azurerm_network_manager_ipam_pool_static_cidr.mccs_observability[0].address_prefixes[0] : null

  # VNet address space (from IPAM or static)
  vnet_address_space = var.use_ipam ? local.ipam_base_cidr : var.vnet_address_space

  # Subnet CIDR computation:
  # - IPAM allocates /24 (256 addresses)
  # - cidrsubnet(base, 2, index) splits /24 into four /26 subnets (64 addresses each)
  # - We use indices 0, 1, 2 for our three subnets
  container_subnet_cidr        = cidrsubnet(local.vnet_address_space, 2, 0)
  postgresql_subnet_cidr       = cidrsubnet(local.vnet_address_space, 2, 1)
  private_endpoint_subnet_cidr = cidrsubnet(local.vnet_address_space, 2, 2)

  # Tags with defaults
  default_tags = {
    Environment = var.environment
    Application = "MCCS-Observability"
    ManagedBy   = "Terraform"
  }
  tags = merge(local.default_tags, var.tags)

  # PostgreSQL configuration
  postgresql_database_name = "netbox"

  # Grafana data sources configuration
  grafana_azure_monitor_data_source = {
    name = "Azure Monitor"
    type = "grafana-azure-monitor-datasource"
  }

  # Alert severity mapping
  alert_severities = {
    "Sev0" = 0 # Critical
    "Sev1" = 1 # Error
    "Sev2" = 2 # Warning
    "Sev3" = 3 # Info
  }

  # ExpressRoute circuit IDs for easier reference
  expressroute_circuit_ids = {
    for k, v in data.azurerm_express_route_circuit.circuits : k => v.id
  }

  # ExpressRoute gateway IDs for easier reference
  expressroute_gateway_ids = {
    for k, v in data.azurerm_virtual_network_gateway.gateways : k => v.id
  }
}
