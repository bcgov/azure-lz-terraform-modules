output "vnet_id" {
  value = module.compute_expansion.vnet_id
}

output "private_nat_private_ip" {
  value = module.compute_expansion.private_nat_private_ip
}

output "private_nat_vm_id" {
  value = module.compute_expansion.private_nat_vm_id
}

output "required_private_snat" {
  value = module.compute_expansion.required_private_snat
}

output "route_table_ids" {
  value = module.compute_expansion.route_table_ids
}
