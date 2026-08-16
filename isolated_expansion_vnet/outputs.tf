output "vnet_id" {
  description = "Resource ID of the isolated expansion Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the isolated expansion Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "address_space" {
  description = "Address space assigned to the isolated expansion Virtual Network."
  value       = azurerm_virtual_network.this.address_space
}

output "subnet_ids" {
  description = "Map of subnet keys to subnet resource IDs."
  value       = local.subnet_ids
}

output "subnet_prefixes" {
  description = "Map of subnet keys to subnet address prefixes."
  value       = local.subnet_prefixes
}

output "peering_ids" {
  description = "Resource IDs for both sides of the expansion-to-routable peering."
  value = {
    expansion_to_routable = azurerm_virtual_network_peering.expansion_to_routable.id
    routable_to_expansion = azurerm_virtual_network_peering.routable_to_expansion.id
  }
}

output "egress_mode" {
  description = "Configured egress mode: nat, firewall_snat, private_nat, or none."
  value       = local.egress_mode
}

output "nat_gateway_id" {
  description = "NAT Gateway resource ID when egress.mode is nat; otherwise null."
  value       = local.nat_enabled ? azurerm_nat_gateway.this[0].id : null
}

output "nat_public_ips" {
  description = "Public IP addresses used by the NAT Gateway when egress.mode is nat; otherwise null."
  value       = local.nat_enabled ? azurerm_public_ip.nat[*].ip_address : null
}

output "firewall_private_ip" {
  description = "Firewall private IP used as the SNAT/routing boundary when egress.mode is firewall_snat; otherwise null."
  value       = local.firewall_enabled ? local.firewall.firewall_private_ip : null
}

output "private_nat_private_ip" {
  description = "Spoke NVA private IP used as the SNAT/routing boundary when egress.mode is private_nat; otherwise null."
  value       = local.private_nat_ip
}

output "private_nat_vm_id" {
  description = "Resource ID of the private NAT NVA when egress.mode is private_nat; otherwise null."
  value       = local.private_nat_enabled ? azurerm_linux_virtual_machine.private_nat[0].id : null
}

output "private_nat_subnet_id" {
  description = "Resource ID of the spoke NVA subnet when egress.mode is private_nat; otherwise null."
  value       = local.private_nat_enabled ? azapi_resource.private_nat_subnet[0].id : null
}

output "egress_route_table_id" {
  description = "Route table ID for the active egress mode. Null in NAT mode. none, private_nat, and firewall_snat share one table so a mode change updates routes in place instead of deleting an in-use table. Callers that create their own subnets should associate this ID."
  value       = local.egress_route_table_id
}

output "route_table_ids" {
  description = "Map of the active egress mode name to its route table ID. Empty in NAT mode. none, private_nat, and firewall_snat resolve to the same table. Prefer egress_route_table_id when associating caller-managed subnets."
  value = merge(
    local.none_enabled ? { none = azurerm_route_table.expansion[0].id } : {},
    local.private_nat_enabled ? { private_nat = azurerm_route_table.expansion[0].id } : {},
    local.firewall_enabled ? { firewall = azurerm_route_table.expansion[0].id } : {}
  )
}

output "dns_forwarding_ruleset_link_id" {
  description = "Resource ID of the expansion VNet link to dns_forwarding_ruleset_id when that input is set; otherwise null."
  value       = local.dns_forwarding_ruleset_link_enabled ? azurerm_private_dns_resolver_virtual_network_link.expansion[0].id : null
}

output "nsg_ids" {
  description = "Map of subnet keys to NSG resource IDs created by this module."
  value       = { for key, nsg in azurerm_network_security_group.this : key => nsg.id }
}

output "required_firewall_routes" {
  description = "Routes a higher-level networking deployment should honour on the firewall path. Null unless egress.mode is firewall_snat."
  value       = local.required_firewall_routes
}

output "required_firewall_rules" {
  description = "Suggested firewall allow sources and destinations for isolated expansion traffic. Null unless egress.mode is firewall_snat."
  value       = local.required_firewall_rules
}

output "required_private_snat" {
  description = "Private SNAT contract: isolated source prefixes that must be translated to an enterprise-routable IP (hub firewall or spoke NVA) before entering the enterprise routing domain. Null unless egress.mode is firewall_snat or private_nat."
  value       = local.required_private_snat
}

output "network_classification" {
  description = "Platform classification for this VNet. Isolated expansion VNets must not receive enterprise-routed spoke automation such as vWAN connections."
  value       = "isolated_expansion"
}

output "spoke_dns_resolver_inbound_ip" {
  description = "Private IP of the spoke DNS resolver inbound endpoint when spoke_dns_resolver is enabled; otherwise null. The expansion VNet uses this as its custom DNS server."
  value       = local.spoke_dns_resolver_inbound_ip
}

output "spoke_dns_resolver_id" {
  description = "Resource ID of the spoke DNS Private Resolver when spoke_dns_resolver is enabled; otherwise null."
  value       = local.spoke_dns_resolver_enabled ? azurerm_private_dns_resolver.spoke[0].id : null
}
