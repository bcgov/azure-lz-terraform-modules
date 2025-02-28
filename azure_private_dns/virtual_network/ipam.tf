resource "azureipam_reservation" "private_dns_resolver" {
  space       = "bcgov-managed-lz-${lower(var.environment)}"
  # blocks       = ["bcgov-managed-lz-${lower(var.environment)}"]
  block       = "bcgov-managed-lz-${lower(var.environment)}"
  size        = 23 # NOTE: Two /24 subnets are required for the Azure Private DNS Resolvers (https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview#virtual-network-restrictions)
  description = "Azure Private DNS Resolvers"
}
