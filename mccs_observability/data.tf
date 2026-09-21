data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "aws_access_key_id" {
  count = local.can_provision_dashboards && var.enable_aws_cloudwatch ? 1 : 0

  name         = var.aws_access_key_secret_name
  key_vault_id = azurerm_key_vault.this.id
}

data "azurerm_key_vault_secret" "aws_secret_access_key" {
  count = local.can_provision_dashboards && var.enable_aws_cloudwatch ? 1 : 0

  name         = var.aws_secret_key_secret_name
  key_vault_id = azurerm_key_vault.this.id
}

data "azurerm_management_group" "grafana_scope" {
  count = var.grafana_monitoring_management_group_id != null ? 1 : 0
  name  = var.grafana_monitoring_management_group_id
}

# Look up Cloud Team Entra ID group by display name
data "azuread_group" "cloud_team" {
  display_name     = var.cloud_team_group_name
  security_enabled = true
}

# Reference existing ExpressRoute circuits for diagnostic settings
data "azurerm_express_route_circuit" "circuits" {
  for_each = var.expressroute_circuits

  name                = each.value.circuit_name
  resource_group_name = each.value.resource_group_name
}

# Reference existing ExpressRoute gateways for diagnostic settings
data "azurerm_virtual_network_gateway" "gateways" {
  for_each = var.expressroute_gateways

  name                = each.value.gateway_name
  resource_group_name = each.value.resource_group_name
}

# Reference existing VPN gateways (vWAN hub VPN gateways) for diagnostics
data "azurerm_vpn_gateway" "vpn_gateways" {
  for_each = var.vpn_gateways

  name                = each.value.gateway_name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_firewall" "azure_firewalls" {
  for_each = var.azure_firewalls

  name                = each.value.firewall_name
  resource_group_name = each.value.resource_group_name
}
