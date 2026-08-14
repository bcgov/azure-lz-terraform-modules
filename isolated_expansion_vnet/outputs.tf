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
  description = "Configured egress mode: nat or firewall_snat."
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

output "route_table_ids" {
  description = "Map of route table names to IDs created for firewall SNAT mode. Empty in NAT mode."
  value = local.firewall_enabled ? {
    firewall = azurerm_route_table.firewall[0].id
  } : {}
}

output "private_dns_link_ids" {
  description = "Map of private DNS virtual network link keys to resource IDs."
  value       = { for key, link in azurerm_private_dns_zone_virtual_network_link.this : key => link.id }
}

output "nsg_ids" {
  description = "Map of subnet keys to NSG resource IDs created by this module."
  value       = { for key, nsg in azurerm_network_security_group.this : key => nsg.id }
}

output "required_firewall_routes" {
  description = "Routes a higher-level networking deployment should honour on the firewall path. Null in NAT mode."
  value       = local.required_firewall_routes
}

output "required_firewall_rules" {
  description = "Suggested firewall allow sources and destinations for isolated expansion traffic. Null in NAT mode."
  value       = local.required_firewall_rules
}

output "required_private_snat" {
  description = "Private SNAT contract: isolated source prefixes that must be translated to the firewall's enterprise-routable IP before entering the enterprise routing domain. Null in NAT mode."
  value       = local.required_private_snat
}

output "network_classification" {
  description = "Platform classification for this VNet. Isolated expansion VNets must not receive enterprise-routed spoke automation such as vWAN connections."
  value       = "isolated_expansion"
}
