resource "azurerm_virtual_network" "ghrunners_vnet" {
  name                           = var.virtual_network_name
  location                       = var.location
  resource_group_name            = azurerm_resource_group.ghrunners.name
  address_space                  = local.vnet_address_space # Uses full IPAM allocation or default
  dns_servers                    = local.dns_servers
  private_endpoint_vnet_policies = "Basic"

  subnet {
    name                                          = var.github_hosted_runners_subnet_name
    address_prefixes                              = local.subnet_address_prefix
    default_outbound_access_enabled               = false
    private_endpoint_network_policies             = "Enabled"
    private_link_service_network_policies_enabled = true

    delegation = [
      {
        name = "githubHostedRunnersDelegation"
        service_delegation = [
          {
            name    = "GitHub.Network/networkSettings"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        ]
      }
    ]
    security_group = azurerm_network_security_group.github_hosted_runners_nsg.id
  }
  tags = var.tags
}
