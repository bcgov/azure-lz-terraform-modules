# Example of how a GitHub runner network wrapper would call the core module.

module "runner_expansion" {
  source = "../.."

  name                = "runners-isolated-expansion"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["10.10.0.0/16"]

  routable_vnet = {
    id                  = var.routable_vnet_id
    name                = var.routable_vnet_name
    resource_group_name = var.routable_vnet_resource_group_name
    address_space       = var.routable_vnet_address_space
  }

  subnets = {
    runners = {
      address_prefix = "10.10.0.0/22"

      delegation = {
        service_name = "GitHub.Network/networkSettings"
      }

      nsg_rules = {
        AllowOutboundGitHub = {
          priority                   = 400
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "Internet"
          description                = "Allow runner egress to GitHub. Tighten destinations in a dedicated wrapper."
        }
      }
    }
  }

  egress = {
    mode = "nat"
  }

  dns_forwarding_ruleset_id = var.dns_forwarding_ruleset_id
}
