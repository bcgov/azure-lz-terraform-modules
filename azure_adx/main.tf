# Resource Group
resource "azurerm_resource_group" "adx" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# ADX Cluster
resource "azurerm_kusto_cluster" "adx" {
  name                = var.adx_cluster_name
  location            = azurerm_resource_group.adx.location
  resource_group_name = azurerm_resource_group.adx.name
  tags                = var.tags

  disk_encryption_enabled     = var.adx_disk_encryption_enabled
  streaming_ingestion_enabled = var.adx_streaming_ingestion_enabled
  purge_enabled               = var.adx_purge_enabled
  double_encryption_enabled   = var.adx_double_encryption_enabled

  sku {
    name     = var.adx_sku
    capacity = var.adx_capacity
  }
}

# ADX Database
resource "azurerm_kusto_database" "adx" {
  name                = var.adx_database_name
  resource_group_name = azurerm_resource_group.adx.name
  location            = azurerm_resource_group.adx.location
  cluster_name        = azurerm_kusto_cluster.adx.name

  hot_cache_period   = var.adx_hot_cache_period
  soft_delete_period = var.adx_soft_delete_period
}

# Event Hub Namespace
resource "azurerm_eventhub_namespace" "adx" {
  name                = var.eventhub_namespace_name
  location            = azurerm_resource_group.adx.location
  resource_group_name = azurerm_resource_group.adx.name
  sku                 = var.eventhub_sku
  capacity            = var.eventhub_capacity
  tags                = var.tags

  auto_inflate_enabled     = var.eventhub_auto_inflate_enabled
  maximum_throughput_units = var.eventhub_auto_inflate_enabled ? var.eventhub_maximum_throughput_units : null
}

# Event Hub
resource "azurerm_eventhub" "adx" {
  name              = var.eventhub_name
  namespace_id      = azurerm_eventhub_namespace.adx.id
  partition_count   = var.eventhub_partition_count
  message_retention = var.eventhub_message_retention

  dynamic "capture_description" {
    for_each = var.eventhub_enable_capture ? [1] : []
    content {
      enabled             = true
      encoding            = var.eventhub_capture_encoding_format
      interval_in_seconds = var.eventhub_capture_interval_in_seconds
      size_limit_in_bytes = var.eventhub_capture_size_limit_in_bytes
      skip_empty_archives = var.eventhub_capture_skip_empty_archives

      destination {
        name                = "EventHubArchive.AzureBlockBlob"
        archive_name_format = var.eventhub_capture_archive_name_format
        blob_container_name = var.eventhub_capture_container_name
        storage_account_id  = var.eventhub_capture_storage_account_id
      }
    }
  }
}

# Event Hub Consumer Group
resource "azurerm_eventhub_consumer_group" "adx" {
  name                = var.eventhub_consumer_group_name
  namespace_name      = azurerm_eventhub_namespace.adx.name
  eventhub_name       = azurerm_eventhub.adx.name
  resource_group_name = azurerm_resource_group.adx.name
  user_metadata       = var.eventhub_consumer_group_metadata
}

# Data Connection
resource "azurerm_kusto_eventhub_data_connection" "adx" {
  name                = var.adx_data_connection_name
  resource_group_name = azurerm_resource_group.adx.name
  location            = azurerm_resource_group.adx.location
  cluster_name        = azurerm_kusto_cluster.adx.name
  database_name       = azurerm_kusto_database.adx.name

  eventhub_id    = azurerm_eventhub.adx.id
  consumer_group = azurerm_eventhub_consumer_group.adx.name

  table_name        = var.adx_table_settings != null ? var.adx_table_settings.table_name : null
  mapping_rule_name = var.adx_table_settings != null ? var.adx_table_settings.mapping_rule_name : null
  data_format       = var.adx_table_settings != null ? var.adx_table_settings.data_format : null
  compression       = var.adx_table_settings != null ? var.adx_table_settings.compression : null
}
