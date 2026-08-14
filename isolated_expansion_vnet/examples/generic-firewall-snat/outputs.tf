output "vnet_id" {
  value = module.compute_expansion.vnet_id
}

output "required_firewall_routes" {
  value = module.compute_expansion.required_firewall_routes
}

output "required_firewall_rules" {
  value = module.compute_expansion.required_firewall_rules
}

output "required_private_snat" {
  value = module.compute_expansion.required_private_snat
}
