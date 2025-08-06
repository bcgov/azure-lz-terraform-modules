# NOTE: The Resource Group is created with the Root Firewall Policy
### Child Firewall Policy

module "lz_firewall_policy" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_firewall/firewall_policy?ref=v0.0.13"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  firewall_policy_name = var.lz_firewall_policy_name
  resource_group_name  = azurerm_resource_group.base_firewall_policy.name
  location             = var.primary_location

  base_policy_id    = azurerm_firewall_policy.base_firewall_policy.id
  dns               = var.dns ## TODO: Update to use module output
  private_ip_ranges = var.private_ip_ranges != null ? var.private_ip_ranges : []

  insights = {
    enabled                            = true
    default_log_analytics_workspace_id = "${values(module.management.log_analytics_workspace)[0].id}"
    retention_in_days                  = 90
  }

  sku = var.sku

  # NOTE: "Threat Intel Mode should be stricter than the Base Policy", therefore using the Base Policy's Threat Intel Mode
  threat_intelligence_mode = var.threat_intelligence_mode
}

module "lz_firewall_policy_rules" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_firewall/firewall_policy_rcg?ref=v0.0.13"
  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  firewall_policy_id                    = module.lz_firewall_policy.firewall_policy_id
  firewall_policy_rule_collection_group = var.lz_firewall_policy_rule_collection_group
}
