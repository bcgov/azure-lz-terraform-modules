resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "traffic_collector" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_network_function/azure_traffic_collector?ref=v0.0.0"
  source = "../azure_traffic_collector" # For local testing only

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  collector_name      = var.collector_name
}

module "traffic_collector_policy" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_network_function/collector_policy?ref=v0.0.0"
  source = "../collector_policy" # For local testing only

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  location            = azurerm_resource_group.this.location

  collector_policy_name = var.collector_policy_name
  traffic_collector_id  = module.traffic_collector.collector_id
  ipfx_emission_destination_types         = var.ipfx_emission_destination_types
  ipfx_ingestion_source_resource_ids        = var.ipfx_ingestion_source_resource_ids
}
