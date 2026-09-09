#------------------------------------------------------------------------------
# Resource Group Outputs
#------------------------------------------------------------------------------

output "resource_group_id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.this.id
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}

#------------------------------------------------------------------------------
# IPAM Outputs
#------------------------------------------------------------------------------

output "ipam_allocation_id" {
  description = "The ID of the IPAM allocation (null if not using IPAM)."
  value       = var.use_ipam ? azurerm_network_manager_ipam_pool_static_cidr.mccs_observability[0].id : null
}

output "ipam_allocated_cidr" {
  description = "The CIDR block allocated from IPAM (null if not using IPAM)."
  value       = var.use_ipam ? try(azurerm_network_manager_ipam_pool_static_cidr.mccs_observability[0].address_prefixes[0], null) : null
}

#------------------------------------------------------------------------------
# VNet Outputs
#------------------------------------------------------------------------------

output "vnet_id" {
  description = "The ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network."
  value       = tolist(azurerm_virtual_network.this.address_space)[0]
}

#------------------------------------------------------------------------------
# Virtual WAN Hub Connection Outputs
#------------------------------------------------------------------------------

output "virtual_hub_connection_id" {
  description = "The ID of the Virtual Hub Connection."
  value       = azurerm_virtual_hub_connection.this.id
}

#------------------------------------------------------------------------------
# Subnet Outputs
#------------------------------------------------------------------------------

output "subnet_containers_id" {
  description = "The ID of the container instances subnet."
  value       = azurerm_subnet.containers.id
}

output "subnet_postgresql_id" {
  description = "The ID of the PostgreSQL subnet."
  value       = azurerm_subnet.postgresql.id
}

output "subnet_private_endpoints_id" {
  description = "The ID of the private endpoints subnet."
  value       = azurerm_subnet.private_endpoints.id
}

output "subnets" {
  description = "Map of all created subnets with IDs and CIDRs."
  value = {
    containers = {
      id   = azurerm_subnet.containers.id
      cidr = local.container_subnet_cidr
    }
    postgresql = {
      id   = azurerm_subnet.postgresql.id
      cidr = local.postgresql_subnet_cidr
    }
    private_endpoints = {
      id   = azurerm_subnet.private_endpoints.id
      cidr = local.private_endpoint_subnet_cidr
    }
  }
}

#------------------------------------------------------------------------------
# Key Vault Outputs
#------------------------------------------------------------------------------

output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

#------------------------------------------------------------------------------
# Log Analytics Outputs
#------------------------------------------------------------------------------

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_primary_key" {
  description = "The primary shared key of the Log Analytics Workspace."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

#------------------------------------------------------------------------------
# PostgreSQL Outputs
#------------------------------------------------------------------------------

output "postgresql_server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "postgresql_fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgresql_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.name
}

#------------------------------------------------------------------------------
# Azure Monitor Workspace Outputs
#------------------------------------------------------------------------------

output "azure_monitor_workspace_id" {
  description = "The ID of the Azure Monitor Workspace."
  value       = azurerm_monitor_workspace.this.id
}

output "azure_monitor_workspace_name" {
  description = "The name of the Azure Monitor Workspace."
  value       = azurerm_monitor_workspace.this.name
}

#------------------------------------------------------------------------------
# Grafana Outputs
#------------------------------------------------------------------------------

output "grafana_id" {
  description = "The ID of the Azure Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.id
}

output "grafana_endpoint" {
  description = "The endpoint URL of the Azure Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.endpoint
}

output "grafana_name" {
  description = "The name of the Azure Managed Grafana instance."
  value       = azurerm_dashboard_grafana.this.name
}

output "grafana_identity_principal_id" {
  description = "The principal ID of the Grafana managed identity."
  value       = azurerm_dashboard_grafana.this.identity[0].principal_id
}

#------------------------------------------------------------------------------
# Grafana Dashboard Outputs
# Note: Dashboards are only provisioned when enable_grafana_dashboards = true
# AND a valid grafana_service_account_token is provided
#------------------------------------------------------------------------------

output "grafana_dashboard_folder_uid" {
  description = "The UID of the MCCS Grafana dashboard folder (null if dashboards not provisioned)."
  value       = length(grafana_folder.mccs) > 0 ? grafana_folder.mccs[0].uid : null
}

output "grafana_dashboard_mccs_overview_url" {
  description = "The URL for the MCCS Overview dashboard."
  value       = length(grafana_dashboard.mccs_overview) > 0 ? "${azurerm_dashboard_grafana.this.endpoint}/d/mccs-overview/mccs-overview" : null
}

output "grafana_dashboard_expressroute_health_url" {
  description = "The URL for the ExpressRoute Health dashboard."
  value       = length(grafana_dashboard.expressroute_health) > 0 ? "${azurerm_dashboard_grafana.this.endpoint}/d/expressroute-health/expressroute-health" : null
}

output "grafana_dashboard_circuit_inventory_url" {
  description = "The URL for the Circuit Inventory dashboard."
  value       = length(grafana_dashboard.circuit_inventory) > 0 ? "${azurerm_dashboard_grafana.this.endpoint}/d/circuit-inventory/circuit-inventory" : null
}

output "grafana_dashboards" {
  description = "Map of all provisioned Grafana dashboard URLs (null if dashboards not provisioned)."
  value = length(grafana_dashboard.mccs_overview) > 0 ? {
    mccs_overview       = "${azurerm_dashboard_grafana.this.endpoint}/d/mccs-overview/mccs-overview"
    expressroute_health = "${azurerm_dashboard_grafana.this.endpoint}/d/expressroute-health/expressroute-health"
    circuit_inventory   = "${azurerm_dashboard_grafana.this.endpoint}/d/circuit-inventory/circuit-inventory"
  } : null
}

#------------------------------------------------------------------------------
# Container Instance Outputs
#------------------------------------------------------------------------------

output "netbox_private_ip" {
  description = "The private IP address of the Netbox container instance. Use this for Prometheus scraping and Grafana data source configuration."
  value       = azurerm_container_group.netbox.ip_address
}

output "netbox_url" {
  description = "The URL for accessing Netbox (using private IP)."
  value       = "http://${azurerm_container_group.netbox.ip_address}:8080"
}

output "prometheus_private_ip" {
  description = "The private IP address of the Prometheus container instance."
  value       = azurerm_container_group.prometheus.ip_address
}

output "prometheus_url" {
  description = "The URL for accessing Prometheus (using private IP)."
  value       = "http://${azurerm_container_group.prometheus.ip_address}:9090"
}

#------------------------------------------------------------------------------
# Alerting Outputs
#------------------------------------------------------------------------------

output "action_group_id" {
  description = "The ID of the alert action group."
  value       = var.enable_alerting ? azurerm_monitor_action_group.this[0].id : null
}

output "logic_app_callback_url" {
  description = "The callback URL for the Logic App HTTP trigger."
  value       = var.enable_alerting ? azurerm_logic_app_trigger_http_request.alert_trigger[0].callback_url : null
  sensitive   = true
}

output "logic_app_id" {
  description = "The ID of the Logic App."
  value       = var.enable_alerting ? azurerm_logic_app_workflow.alert_router[0].id : null
}

#------------------------------------------------------------------------------
# Identity Outputs
#------------------------------------------------------------------------------

output "grafana_managed_identity_id" {
  description = "The ID of the Grafana managed identity."
  value       = azurerm_dashboard_grafana.this.identity[0].principal_id
}

output "logic_app_managed_identity_id" {
  description = "The ID of the Logic App managed identity."
  value       = var.enable_alerting ? azurerm_logic_app_workflow.alert_router[0].identity[0].principal_id : null
}

#------------------------------------------------------------------------------
# Storage Outputs
#------------------------------------------------------------------------------

output "prometheus_storage_account_name" {
  description = "The name of the Prometheus storage account."
  value       = azurerm_storage_account.prometheus.name
}

output "netbox_storage_account_name" {
  description = "The name of the Netbox storage account."
  value       = azurerm_storage_account.netbox.name
}

#------------------------------------------------------------------------------
# Jump Box Outputs
#------------------------------------------------------------------------------

output "jumpbox_private_ip" {
  description = "The private IP address of the Windows jump box."
  value       = var.deploy_jumpbox ? azurerm_network_interface.jumpbox[0].private_ip_address : null
}

output "jumpbox_name" {
  description = "The name of the Windows jump box VM."
  value       = var.deploy_jumpbox ? azurerm_windows_virtual_machine.jumpbox[0].name : null
}

output "jumpbox_admin_username" {
  description = "The admin username for the jump box."
  value       = var.deploy_jumpbox ? var.jumpbox_admin_username : null
}
