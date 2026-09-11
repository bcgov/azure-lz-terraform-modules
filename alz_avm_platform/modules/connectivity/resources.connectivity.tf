resource "azurerm_resource_group" "vwan" {
  name     = var.vwan_resource_group_name
  location = var.location

  provider = azurerm.connectivity
}

resource "azurerm_resource_group" "dns_zones" {
  name     = local.private_dns_zones_resource_group_name
  location = var.location

  provider = azurerm.connectivity
}

resource "azurerm_resource_group" "private_dns_resolver" {
  name     = local.private_dns_resolver_resource_group_name
  location = var.location

  provider = azurerm.connectivity
}

resource "azurerm_resource_group" "firewall_policy" {
  name     = local.firewall_policy_resource_group_name
  location = var.location

  provider = azurerm.connectivity
}

# One NSG per DNS resolver endpoint subnet (inbound_endpoint/outbound_endpoint); outbound_endpoint keeps only Azure defaults.
resource "azurerm_network_security_group" "dns_resolver_endpoint" {
  for_each = local.dns_resolver_endpoint_subnets

  name                = "nsg-${each.value.subnet_name}-${each.value.hub_key}"
  location            = each.value.location
  resource_group_name = local.private_dns_resolver_resource_group_name

  provider = azurerm.connectivity

  dynamic "security_rule" {
    for_each = each.value.subnet_key == "inbound_endpoint" ? {
      AllowDNSUdpInbound = {
        priority           = 110
        direction          = "Inbound"
        access             = "Allow"
        protocol           = "Udp"
        destination_port   = "53"
        destination_prefix = "VirtualNetwork"
        description        = "Allow inbound UDP DNS traffic from any source to port 53"
      }

      AllowDNSTcpInbound = {
        priority           = 111
        direction          = "Inbound"
        access             = "Allow"
        protocol           = "Tcp"
        destination_port   = "53"
        destination_prefix = "VirtualNetwork"
        description        = "Allow inbound TCP DNS traffic from any source to port 53"
      }

      DenyAllOutbound = {
        priority           = 120
        direction          = "Outbound"
        access             = "Deny"
        protocol           = "*"
        destination_port   = "*"
        destination_prefix = "*"
        description        = "Block all other outbound traffic"
      }
    } : {}

    content {
      name                       = security_rule.key
      description                = security_rule.value.description
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.destination_port
      source_address_prefix      = "*"
      destination_address_prefix = security_rule.value.destination_prefix
    }
  }

  depends_on = [azurerm_resource_group.private_dns_resolver]
}

module "avm-ptn-alz-connectivity-virtual-wan" {
  source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm"
  version = "0.17.1"

  depends_on = [
    azurerm_resource_group.vwan,
    azurerm_resource_group.dns_zones,
    azurerm_resource_group.private_dns_resolver,
    azurerm_resource_group.firewall_policy,
    azurerm_network_security_group.dns_resolver_endpoint
  ]

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi.connectivity
  }

  default_naming_convention          = var.default_naming_convention
  default_naming_convention_sequence = var.default_naming_convention_sequence
  route_maps                         = var.route_maps
  tags                               = var.tags
  virtual_hubs                       = local.virtual_hubs_with_dns_resolver_nsgs
  virtual_wan_settings               = var.virtual_wan_settings
}
