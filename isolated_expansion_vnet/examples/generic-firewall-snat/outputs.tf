output "vnet_id" {
  value = module.compute_expansion.vnet_id
}

output "firewall_id" {
  value = module.compute_expansion.firewall_id
}

output "firewall_private_ip" {
  value = module.compute_expansion.firewall_private_ip
}

output "required_private_snat" {
  value = module.compute_expansion.required_private_snat
}
