#------------------------------------------------------------------------------
# Outputs
#------------------------------------------------------------------------------

output "resource_group_name" {
  description = "The name of the resource group."
  value       = module.mccs_observability.resource_group_name
}

output "vnet_id" {
  description = "The VNet ID."
  value       = module.mccs_observability.vnet_id
}

output "vnet_address_space" {
  description = "The VNet address space."
  value       = module.mccs_observability.vnet_address_space
}

output "subnets" {
  description = "Map of subnet IDs and CIDRs."
  value       = module.mccs_observability.subnets
}

output "grafana_endpoint" {
  description = "The Grafana endpoint URL."
  value       = module.mccs_observability.grafana_endpoint
}

output "netbox_private_ip" {
  description = "The private IP of the Netbox container."
  value       = module.mccs_observability.netbox_private_ip
}

output "prometheus_private_ip" {
  description = "The private IP of the Prometheus container."
  value       = module.mccs_observability.prometheus_private_ip
}

output "postgresql_fqdn" {
  description = "The PostgreSQL server FQDN."
  value       = module.mccs_observability.postgresql_fqdn
}

output "key_vault_uri" {
  description = "The Key Vault URI."
  value       = module.mccs_observability.key_vault_uri
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics Workspace ID."
  value       = module.mccs_observability.log_analytics_workspace_id
}
