resource "azurerm_resource_group" "adx" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kusto_cluster" "adx" {
  name                        = var.adx_cluster_name
  location                    = azurerm_resource_group.adx.location
  resource_group_name         = azurerm_resource_group.adx.name
  disk_encryption_enabled     = true
  streaming_ingestion_enabled = true

  sku {
    name     = var.adx_sku
    capacity = var.adx_capacity
  }

}
resource "azurerm_kusto_database" "adx" {
  name                = var.adx_cluster_name
  resource_group_name = azurerm_resource_group.adx.name
  location            = azurerm_resource_group.adx.location
  cluster_name        = azurerm_kusto_cluster.adx.name

  hot_cache_period   = "P7D"
  soft_delete_period = "P31D"
}

resource "azurerm_eventhub_namespace" "adx" {
  name                = var.event_hub_namespace_name
  location            = azurerm_resource_group.adx.location
  resource_group_name = azurerm_resource_group.adx.name
  sku                 = var.event_hub_sku
}

resource "azurerm_eventhub" "adx" {
  name              = var.event_hub_name
  namespace_id      = azurerm_eventhub_namespace.adx.id
  partition_count   = var.event_hub_partition_count
  message_retention = var.event_hub_message_retention
}

resource "azurerm_eventhub_consumer_group" "adx" {
  name                = var.event_hub_consumer_group_name
  namespace_name      = azurerm_eventhub_namespace.adx.name
  eventhub_name       = azurerm_eventhub.adx.name
  resource_group_name = azurerm_resource_group.adx.name
}

resource "azurerm_kusto_eventhub_data_connection" "adx" {
  name                = var.data_connection_name
  resource_group_name = azurerm_resource_group.adx.name
  location            = azurerm_resource_group.adx.location
  cluster_name        = azurerm_kusto_cluster.adx.name
  database_name       = azurerm_kusto_database.adx.name

  eventhub_id    = azurerm_eventhub.adx.id
  consumer_group = azurerm_eventhub_consumer_group.adx.name

  #   table_name        = "my-table"         #(Optional)
  #   mapping_rule_name = "my-table-mapping" #(Optional)
  #   data_format       = "JSON"             #(Optional)
}
