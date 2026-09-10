output "vnet_id" {
  value = module.compute_expansion.vnet_id
}

output "subnet_ids" {
  value = module.compute_expansion.subnet_ids
}

output "egress_mode" {
  value = module.compute_expansion.egress_mode
}

output "nat_gateway_id" {
  value = module.compute_expansion.nat_gateway_id
}

output "route_table_ids" {
  value = module.compute_expansion.route_table_ids
}
