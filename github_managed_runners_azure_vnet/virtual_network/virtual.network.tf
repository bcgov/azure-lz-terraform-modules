resource "azurerm_virtual_network" "ghrunners_vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = azurerm_resource_group.ghrunners.name
  address_space       = try([azurerm_network_manager_ipam_pool_static_cidr.reservations.address_prefixes[0]], ["192.168.0.0"]) // From Azure IPAM
  dns_servers         = local.dns_servers

  subnet {
    name                            = var.github_hosted_runners_subnet_name
    address_prefixes                = try([cidrsubnet(azurerm_network_manager_ipam_pool_static_cidr.reservations.address_prefixes[0], local.newBits, 0)], null) // From Azure IPAM
    default_outbound_access_enabled = false
    delegation = [
      {
        name = "githubHostedRunnersDelegation"
        service_delegation = [
          {
            name    = "Microsoft.GitHub/hostedRunners"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        ]
      }
    ]
    security_group = azurerm_network_security_group.github_hosted_runners_nsg.id
  }
  tags = var.tags
}
