output "ip_groups" {
  description = "Map of created IP Groups"
  value       = module.lz_firewall_ipgroups.ip_groups
}

output "ip_group_ids" {
  description = "Map of IP Group names to their IDs"
  value       = module.lz_firewall_ipgroups.ip_group_ids
}
