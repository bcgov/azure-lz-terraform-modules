module "lz_firewall_policy_rules" {
  source = "../azure_firewall/firewall_policy_rcg"
  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  firewall_policy_id                    = module.connectivity.firewall_policy_resource_ids["primary"]
  firewall_policy_rule_collection_group = var.fw_lz_config.policy_rule_collection_group
}
