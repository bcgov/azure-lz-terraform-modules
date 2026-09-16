# ALZ Module Outputs
# Generic outputs that don't assume specific management group IDs

# Management Groups
output "management_groups" {
  description = "The management groups created by the ALZ module"
  value       = module.avm_ptn_alz.management_group_resource_ids
}

# Policy Resources
output "policy_assignments" {
  description = "The policy assignments created by the ALZ module"
  value       = module.avm_ptn_alz.policy_assignment_resource_ids
}

output "policy_definitions" {
  description = "The policy definitions created by the ALZ module"
  value       = module.avm_ptn_alz.policy_definition_resource_ids
}

output "policy_set_definitions" {
  description = "The policy set definitions created by the ALZ module"
  value       = module.avm_ptn_alz.policy_set_definition_resource_ids
}

# Configuration Outputs (for compatibility with CAF module)
output "configuration" {
  description = "Configuration object for compatibility with CAF module"
  value = {
    management_groups = module.avm_ptn_alz.management_group_resource_ids
    policy_resources = {
      assignments     = module.avm_ptn_alz.policy_assignment_resource_ids
      definitions     = module.avm_ptn_alz.policy_definition_resource_ids
      set_definitions = module.avm_ptn_alz.policy_set_definition_resource_ids
    }
  }
}

# Platform Landing Zone Outputs
output "dns_server_ip_address" {
  description = "DNS server IP address from connectivity module"
  value       = local.connectivity_enabled ? (local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].dns_server_ip_addresses : module.virtual_wan[0].dns_server_ip_address) : null
}

# Hub and Spoke Virtual Network Outputs
output "hub_and_spoke_vnet_virtual_network_resource_ids" {
  description = "Hub and spoke virtual network resource IDs"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].virtual_network_resource_ids : null
}

output "hub_and_spoke_vnet_virtual_network_resource_names" {
  description = "Hub and spoke virtual network resource names"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].virtual_network_resource_names : null
}

output "hub_and_spoke_vnet_firewall_resource_ids" {
  description = "Hub and spoke firewall resource IDs"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].firewall_resource_ids : null
}

output "hub_and_spoke_vnet_firewall_resource_names" {
  description = "Hub and spoke firewall resource names"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].firewall_resource_names : null
}

output "hub_and_spoke_vnet_firewall_private_ip_address" {
  description = "Hub and spoke firewall private IP addresses"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].firewall_private_ip_addresses : null
}

output "hub_and_spoke_vnet_firewall_public_ip_addresses" {
  description = "Hub and spoke firewall public IP addresses"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].firewall_public_ip_addresses : null
}

output "hub_and_spoke_vnet_firewall_policy_ids" {
  description = "Hub and spoke firewall policy IDs"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].firewall_policy_ids : null
}

output "hub_and_spoke_vnet_route_tables_firewall" {
  description = "Hub and spoke route tables for firewall"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].route_tables_firewall : null
}

output "hub_and_spoke_vnet_route_tables_user_subnets" {
  description = "Hub and spoke route tables for user subnets"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0].route_tables_user_subnets : null
}

output "hub_and_spoke_vnet_full_output" {
  description = "Full hub and spoke virtual network module output"
  value       = local.connectivity_hub_and_spoke_vnet_enabled ? module.hub_and_spoke_vnet[0] : null
}

# Virtual WAN Outputs
output "virtual_wan_resource_id" {
  description = "Virtual WAN resource ID"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].resource_id : null
}

output "virtual_wan_name" {
  description = "Virtual WAN name"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].name : null
}

output "virtual_wan_virtual_hub_resource_ids" {
  description = "Virtual WAN virtual hub resource IDs"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].virtual_hub_resource_ids : null
}

output "virtual_wan_virtual_hub_resource_names" {
  description = "Virtual WAN virtual hub resource names"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].virtual_hub_resource_names : null
}

output "virtual_wan_firewall_resource_ids" {
  description = "Virtual WAN firewall resource IDs"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].firewall_resource_ids : null
}

output "virtual_wan_firewall_resource_names" {
  description = "Virtual WAN firewall resource names"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].firewall_resource_names : null
}

output "virtual_wan_firewall_private_ip_address" {
  description = "Virtual WAN firewall private IP address"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].firewall_private_ip_address : null
}

output "virtual_wan_firewall_public_ip_addresses" {
  description = "Virtual WAN firewall public IP addresses"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].firewall_public_ip_addresses : null
}

output "virtual_wan_firewall_policy_ids" {
  description = "Virtual WAN firewall policy IDs"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].firewall_policy_resource_ids : null
}

output "virtual_wan_express_route_gateway_resource_ids" {
  description = "Virtual WAN ExpressRoute gateway resource IDs"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].express_route_gateway_resource_ids : null
}

output "virtual_wan_bastion_host_public_ip_address" {
  description = "Virtual WAN bastion host public IP address"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].bastion_host_public_ip_address : null
}

output "virtual_wan_bastion_host_resource_ids" {
  description = "Virtual WAN bastion host resource IDs"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].bastion_host_resource_ids : null
}

output "virtual_wan_bastion_host_resources" {
  description = "Virtual WAN bastion host resources"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].bastion_host_resources : null
}

output "virtual_wan_private_dns_resolver_resource_ids" {
  description = "Virtual WAN private DNS resolver resource IDs"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].private_dns_resolver_resource_ids : null
}

output "virtual_wan_private_dns_resolver_resources" {
  description = "Virtual WAN private DNS resolver resources"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].private_dns_resolver_resources : null
}

output "virtual_wan_sidecar_virtual_network_resource_ids" {
  description = "Virtual WAN sidecar virtual network resource IDs"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].sidecar_virtual_network_resource_ids : null
}

output "virtual_wan_sidecar_virtual_network_resources" {
  description = "Virtual WAN sidecar virtual network resources"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0].sidecar_virtual_network_resources : null
}

output "virtual_wan_full_output" {
  description = "Full virtual WAN module output"
  value       = local.connectivity_virtual_wan_enabled ? module.virtual_wan[0] : null
}

# Configuration Module Outputs
output "templated_inputs" {
  description = "Templated inputs from configuration module"
  value       = module.config
}

# Management Resources Outputs
output "management_resources" {
  description = "Management resources module output"
  value       = local.management_resources_enabled ? module.management_resources[0] : null
  sensitive   = true
}

# Resource Groups Outputs
output "resource_groups" {
  description = "Resource groups created by the module"
  value       = module.resource_groups
}
