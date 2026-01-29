resource "azurerm_virtual_network" "ghrunners_vnet" {
  name                           = var.virtual_network_name
  location                       = var.location
  resource_group_name            = azurerm_resource_group.ghrunners.name
  address_space                  = local.vnet_address_space
  dns_servers                    = local.dns_servers
  private_endpoint_vnet_policies = "Basic"

  dynamic "subnet" {
    for_each = local.subnet_address_prefix != null && local.subnet_address_prefix[0] != "" ? [local.subnet_address_prefix] : []
    content {
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
  }
  tags = var.tags
}
