resource "azurerm_network_security_group" "spoke_dns_inbound" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                = "${var.routable_vnet.name}-dns-inbound"
  location            = var.location
  resource_group_name = var.routable_vnet.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_rule" "spoke_dns_inbound" {
  for_each = {
    for key, rule in local.spoke_dns_inbound_nsg_rules : key => rule
    if local.spoke_dns_resolver_enabled
  }

  name                         = each.key
  resource_group_name          = var.routable_vnet.resource_group_name
  network_security_group_name  = azurerm_network_security_group.spoke_dns_inbound[0].name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  description                  = each.value.description
  source_port_range            = "*"
  destination_port_range       = each.value.destination_port_range
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
}

resource "azurerm_network_security_group" "spoke_dns_outbound" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                = "${var.routable_vnet.name}-dns-outbound"
  location            = var.location
  resource_group_name = var.routable_vnet.resource_group_name
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_security_rule" "spoke_dns_outbound" {
  for_each = {
    for key, rule in local.spoke_dns_outbound_nsg_rules : key => rule
    if local.spoke_dns_resolver_enabled
  }

  name                         = each.key
  resource_group_name          = var.routable_vnet.resource_group_name
  network_security_group_name  = azurerm_network_security_group.spoke_dns_outbound[0].name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  description                  = each.value.description
  source_port_range            = "*"
  destination_port_range       = each.value.destination_port_range
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
}

resource "azapi_resource" "spoke_dns_subnet" {
  for_each = {
    for key, subnet in local.spoke_dns_subnets : key => subnet
    if local.spoke_dns_resolver_enabled
  }

  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  name      = "dns-${each.key}"
  parent_id = var.routable_vnet.id

  body = {
    properties = {
      addressPrefix         = each.value.address_prefix
      defaultOutboundAccess = false
      networkSecurityGroup = {
        id = each.value.nsg_id
      }
      delegations = [
        {
          name = "Microsoft.Network.dnsResolvers"
          properties = {
            serviceName = "Microsoft.Network/dnsResolvers"
          }
        }
      ]
    }
  }
}

resource "azurerm_private_dns_resolver" "spoke" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                = "${var.routable_vnet.name}-dns-resolver"
  resource_group_name = var.routable_vnet.resource_group_name
  location            = var.location
  virtual_network_id  = var.routable_vnet.id
  tags                = local.tags

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [azapi_resource.spoke_dns_subnet]
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "spoke" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                    = "${var.routable_vnet.name}-dns-inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.spoke[0].id
  location                = var.location
  tags                    = local.tags

  ip_configurations {
    subnet_id                    = azapi_resource.spoke_dns_subnet["inbound"].id
    private_ip_allocation_method = "Static"
    private_ip_address           = local.spoke_dns_resolver_inbound_ip
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "spoke" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                    = "${var.routable_vnet.name}-dns-outbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.spoke[0].id
  location                = var.location
  subnet_id               = azapi_resource.spoke_dns_subnet["outbound"].id
  tags                    = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "spoke" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                = "${var.routable_vnet.name}-dns-forwarding"
  resource_group_name = var.routable_vnet.resource_group_name
  location            = var.location
  private_dns_resolver_outbound_endpoint_ids = [
    azurerm_private_dns_resolver_outbound_endpoint.spoke[0].id
  ]
  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "spoke_all" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                      = "all-to-hub-dns"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.spoke[0].id
  domain_name               = "."
  enabled                   = true

  dynamic "target_dns_servers" {
    for_each = var.spoke_dns_resolver.forward_to
    content {
      ip_address = target_dns_servers.value
      port       = 53
    }
  }
}

resource "azurerm_private_dns_resolver_forwarding_rule" "spoke_additional" {
  for_each = local.spoke_dns_additional_forward_domains

  name                      = each.key
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.spoke[0].id
  domain_name               = each.value
  enabled                   = true

  dynamic "target_dns_servers" {
    for_each = var.spoke_dns_resolver.forward_to
    content {
      ip_address = target_dns_servers.value
      port       = 53
    }
  }
}

resource "azurerm_private_dns_resolver_virtual_network_link" "expansion" {
  count = local.dns_forwarding_ruleset_link_enabled ? 1 : 0

  name                      = local.virtual_network_name
  dns_forwarding_ruleset_id = var.dns_forwarding_ruleset_id
  virtual_network_id        = azurerm_virtual_network.this.id
}

resource "azurerm_private_dns_resolver_virtual_network_link" "spoke" {
  count = local.spoke_dns_resolver_enabled ? 1 : 0

  name                      = "${var.routable_vnet.name}-dns-forwarding"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.spoke[0].id
  virtual_network_id        = var.routable_vnet.id
}
