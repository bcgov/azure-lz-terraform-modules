variable "private_dns_zones" {
  description = "A map of Private DNS Zones to create, where the key is the name of the zone and the value is the resource group name."
  type = map(object({
    private_dns_zone_name = string
    resource_group_name   = string
  }))
}
