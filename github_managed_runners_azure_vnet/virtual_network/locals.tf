locals {
  # Set the DNS server to the Azure Firewall IP based on the environment
  dns_servers = upper(var.environment) == "FORGE" ? ["10.41.253.4"] : ["10.53.244.4"]

  # Default address space as Terraform plan will fail since the IPAM reservation is not created yet
  default_address_space = ["192.168.0.0/30"]

  # Use IPAM if available, fall back to default
  vnet_address_space = (
    try(azurerm_network_manager_ipam_pool_static_cidr.reservations.address_prefixes, null) != null
    ? azurerm_network_manager_ipam_pool_static_cidr.reservations.address_prefixes
    : local.default_address_space
  )

  # Calculate new bits needed for subnetting
  newBits = (var.github_hosted_runners_subnet_address_prefix - var.virtual_network_address_space)

  # Derive subnet from vnet address space
  subnet_address_prefix = [try(
    cidrsubnet(
      local.vnet_address_space[0], # Use first vnet prefix
      local.newBits,
      0 # First subnet
    ),
    "192.168.0.0/30" # NOTE: Cannot be null (though empty string is allowed). Terraform throws an err about "null value found in list"
  )]
}
