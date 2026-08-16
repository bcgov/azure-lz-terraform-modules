# Firewall SNAT mode creates a forced-tunnel Azure Firewall in the routable
# spoke. Expansion traffic is steered to that firewall, which SNATs isolated
# sources to the firewall's spoke IP before packets follow the spoke's
# existing hub/vWAN path. The isolated prefix is never advertised.
#
# AzureFirewallSubnet and AzureFirewallManagementSubnet cannot have NSGs.
# Associate spoke_route_table_id on AzureFirewallSubnet only so SNATed
# packets follow the spoke egress path. Do not put that table on the
# management subnet.

check "firewall_snat_boundary" {
  assert {
    condition     = !local.firewall_enabled || local.firewall != null
    error_message = "egress.firewall is required when egress.mode is firewall_snat."
  }

  assert {
    condition     = !local.firewall_enabled || length(var.routable_vnet.address_space) > 0
    error_message = "routable_vnet.address_space is required when using firewall_snat so the Azure Firewall subnets can be validated against the spoke."
  }

  assert {
    condition     = !local.firewall_enabled || local.firewall_subnet_in_spoke
    error_message = "egress.firewall subnet prefixes must be contained in routable_vnet.address_space."
  }

  assert {
    condition     = !local.firewall_subnets_overlap
    error_message = "egress.firewall.subnet_address_prefix overlaps management_subnet_address_prefix."
  }

  assert {
    condition     = !local.firewall_overlaps_expansion
    error_message = "egress.firewall subnet prefixes must not overlap the isolated expansion address_space."
  }

  assert {
    condition     = !local.firewall_overlaps_dns
    error_message = "egress.firewall subnet prefixes overlap a spoke DNS resolver subnet."
  }

  assert {
    condition     = !local.firewall_overlaps_nva
    error_message = "egress.firewall subnet prefixes overlap the private_nat NVA subnet."
  }

  assert {
    condition     = !local.firewall_enabled || local.firewall_ip_in_subnet
    error_message = "egress.firewall.private_ip must be a usable address in subnet_address_prefix."
  }

  assert {
    condition     = !local.firewall_enabled || try(local.firewall.route_internet_through_firewall, true) || length(var.enterprise_routes) > 0
    error_message = "enterprise_routes is required when firewall_snat is used without route_internet_through_firewall. Otherwise the expansion VNet has no translated path beyond the peer."
  }

  assert {
    condition     = !local.firewall_enabled || try(local.firewall.direct_peer_bypass, true) || length(var.routable_vnet.address_space) > 0
    error_message = "routable_vnet.address_space is required when firewall.direct_peer_bypass is false so peer prefixes can be steered to the firewall."
  }
}

check "none_mode_is_private_only" {
  assert {
    condition     = !local.none_enabled || !local.nat_enabled
    error_message = "egress.mode = none must not create a NAT Gateway."
  }

  assert {
    condition     = !local.none_enabled || length(var.enterprise_routes) == 0
    error_message = "enterprise_routes are ignored when egress.mode is none. Use firewall_snat or private_nat if residual Databricks or enterprise platform endpoints still require a translated path."
  }
}

check "private_nat_boundary" {
  assert {
    condition     = !local.private_nat_enabled || local.private_nat != null
    error_message = "egress.private_nat is required when egress.mode is private_nat."
  }

  assert {
    condition     = !local.private_nat_enabled || try(local.private_nat.route_internet_through_nva, true) || length(var.enterprise_routes) > 0
    error_message = "enterprise_routes is required when private_nat is used without route_internet_through_nva. Otherwise the expansion VNet has no translated path beyond the peer."
  }

  assert {
    condition     = !local.private_nat_enabled || length(var.routable_vnet.address_space) > 0
    error_message = "routable_vnet.address_space is required when using private_nat so the NVA subnet can be validated against the spoke."
  }

  assert {
    condition     = !local.private_nat_enabled || local.private_nat_subnet_in_spoke
    error_message = "egress.private_nat.subnet_address_prefix must be contained in routable_vnet.address_space."
  }

  assert {
    condition     = !local.private_nat_overlaps_expansion
    error_message = "egress.private_nat.subnet_address_prefix must not overlap the isolated expansion address_space."
  }

  assert {
    condition     = !local.private_nat_overlaps_dns
    error_message = "egress.private_nat.subnet_address_prefix overlaps a spoke DNS resolver subnet."
  }

  assert {
    condition     = !local.private_nat_enabled || local.private_nat_ip_in_subnet
    error_message = "egress.private_nat.private_ip must be a usable address in subnet_address_prefix."
  }

  assert {
    condition     = !local.private_nat_enabled || try(local.private_nat.direct_peer_bypass, true) || length(var.routable_vnet.address_space) > 0
    error_message = "routable_vnet.address_space is required when private_nat.direct_peer_bypass is false so peer prefixes can be steered to the NVA."
  }
}

resource "azapi_resource" "firewall_subnet" {
  for_each = local.firewall_subnets

  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"
  name      = each.value.name
  parent_id = var.routable_vnet.id
  locks     = [var.routable_vnet.id]

  body = {
    properties = merge(
      {
        addressPrefix         = each.value.address_prefix
        defaultOutboundAccess = false
      },
      each.value.route_table_id != null ? {
        routeTable = {
          id = each.value.route_table_id
        }
      } : {}
    )
  }
}

resource "azurerm_public_ip" "firewall_data" {
  count = local.firewall_enabled ? 1 : 0

  name                = "${local.virtual_network_name}-azfw"
  location            = var.location
  resource_group_name = var.routable_vnet.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = local.firewall.zones
  tags                = local.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

resource "azurerm_public_ip" "firewall_management" {
  count = local.firewall_enabled ? 1 : 0

  name                = "${local.virtual_network_name}-azfw-mgmt"
  location            = var.location
  resource_group_name = var.routable_vnet.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = local.firewall.zones
  tags                = local.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

resource "azurerm_firewall_policy" "spoke" {
  count = local.firewall_enabled ? 1 : 0

  name                = "${local.virtual_network_name}-azfw"
  location            = var.location
  resource_group_name = var.routable_vnet.resource_group_name
  sku                 = local.firewall.sku_tier
  # Destinations in this list are not SNATed. A dummy range forces SNAT of
  # RFC1918 enterprise destinations so the isolated prefix never enters vWAN.
  private_ip_ranges = ["255.255.255.255/32"]
  tags              = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "spoke" {
  count = local.firewall_enabled ? 1 : 0

  name               = "isolated-expansion"
  firewall_policy_id = azurerm_firewall_policy.spoke[0].id
  priority           = 100

  network_rule_collection {
    name     = "allow-expansion"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "expansion-to-any"
      protocols             = ["Any"]
      source_addresses      = var.address_space
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}

resource "azurerm_firewall" "spoke" {
  count = local.firewall_enabled ? 1 : 0

  name                = "${local.virtual_network_name}-azfw"
  location            = var.location
  resource_group_name = var.routable_vnet.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = local.firewall.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.spoke[0].id
  zones               = local.firewall.zones
  tags                = local.tags

  ip_configuration {
    name                 = "azfw"
    subnet_id            = azapi_resource.firewall_subnet["data"].id
    public_ip_address_id = azurerm_public_ip.firewall_data[0].id
  }

  management_ip_configuration {
    name                 = "azfw-mgmt"
    subnet_id            = azapi_resource.firewall_subnet["management"].id
    public_ip_address_id = azurerm_public_ip.firewall_management[0].id
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [
    azurerm_virtual_network_peering.expansion_to_routable,
    azurerm_virtual_network_peering.routable_to_expansion,
    azurerm_firewall_policy_rule_collection_group.spoke
  ]
}
