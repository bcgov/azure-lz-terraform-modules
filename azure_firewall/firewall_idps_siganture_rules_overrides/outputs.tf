output "firewall_policy_id" {
  value = data.azurerm_firewall_policy.this.id
}

output "object_names" {
  description = "List of object names"
  value       = local.object_names  
}

output "fqdn_names" {
  value = local.fqdn_names
}

output "ip_addresses" {
  value = local.ip_addresses
}

# output "azapi_update_resource_fwpolicy_idps" {
#   value = azapi_update_resource.fwpolicy_idps  
# }