variable "private_dns_zones" {
  description = "A map of Private DNS Zones to create, where the key is the name of the zone and the value is the resource group name."
  type = map(object({
    private_dns_zone_name = string
    resource_group_name   = string
  }))
}

# variable "private_dns_zone_name" {
#   description = "The name of the Private DNS Zone."
#   type        = string
# }

# variable "resource_group_name" {
#   description = "The name of the resource group where the Private DNS Zone will be created."
#   type        = string
# }
