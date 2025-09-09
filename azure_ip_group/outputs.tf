output "ip_groups" {
  description = "Map of created IP Groups"
  value = {
    for k, v in azurerm_ip_group.ipgroup : k => {
      id                  = v.id
      name                = v.name
      location            = v.location
      resource_group_name = v.resource_group_name
      cidrs               = v.cidrs
    }
  }
}

output "ip_group_ids" {
  description = "Map of IP Group names to their IDs"
  value = {
    for k, v in azurerm_ip_group.ipgroup : k => v.id
  }
}
