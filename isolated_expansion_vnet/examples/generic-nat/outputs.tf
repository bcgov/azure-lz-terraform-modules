output "vnet_id" {
  value = module.compute_expansion.vnet_id
}

output "subnet_ids" {
  value = module.compute_expansion.subnet_ids
}

output "nat_gateway_id" {
  value = module.compute_expansion.nat_gateway_id
}

output "nat_public_ips" {
  value = module.compute_expansion.nat_public_ips
}
