resource "azurerm_network_security_group" "inbound_endpoint" {
  name                = "private_dns_inbound"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  # Per the Microsoft documentation (https://learn.microsoft.com/en-us/azure/architecture/networking/guide/private-link-virtual-wan-dns-single-region-workload#azure-dns-private-resolver)
  # The Network Security Group in the subnet for the DNS Private Resolver's inbound endpoint should only allow UDP traffic from its regional hub to port 53. You should block all other inbound and outbound traffic.
  security_rule {
    name                       = "AllowUdpFromRegionalHubVNet"
    description                = "Allow inbound UDP traffic from the regional hub to port 53"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = data.azurerm_virtual_hub.vwan_hub.address_prefix
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllInbound"
    description                = "Block all other inbound traffic"
    priority                   = 115
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllOutbound"
    description                = "Block all other outbound traffic"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "outbound_endpoint" {
  name                = "private_dns_outbound"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_virtual_network" "this" {
  name                = var.private_dns_resolver_virtual_network_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space = [
    azureipam_reservation.private_dns_resolver.cidr
  ]
  dns_servers                    = var.firewall_private_ip_address
  private_endpoint_vnet_policies = "Disabled"

  # NOTE: We are using the cidrsubnet() function, and offsetting the bit position by 1, since the parent CIDR is /23 (and we need to split it into two /24s)
  # IMPORTANT: The subnet property changed in azurerm 4.1.0 from `address_prefix` to `address_prefixes`
  subnet {
    name             = "inbound_endpoint"
    address_prefixes = [cidrsubnet(azureipam_reservation.private_dns_resolver.cidr, 1, 0)]
    security_group   = azurerm_network_security_group.inbound_endpoint.id

    default_outbound_access_enabled = false

    delegation = [
      {
        name = "Microsoft.Network.dnsResolvers"
        service_delegation = [
          {
            name = "Microsoft.Network/dnsResolvers"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action"
            ]
          }
        ]
      }
    ]

    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
  }

  subnet {
    name             = "outbound_endpoint"
    address_prefixes = [cidrsubnet(azureipam_reservation.private_dns_resolver.cidr, 1, 1)]
    security_group   = azurerm_network_security_group.outbound_endpoint.id

    default_outbound_access_enabled = false

    delegation = [
      {
        name = "Microsoft.Network.dnsResolvers"
        service_delegation = [
          {
            name = "Microsoft.Network/dnsResolvers"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action"
            ]
          }
        ]
      }
    ]

    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
  }
}
