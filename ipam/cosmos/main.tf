variable "cosmosAccountName" {
  description = "CosmosDB Account Name"

  type = string
}
variable "cosmosContainerName" {
  description = "CosmosDB Container Name"

  type = string
}
variable "cosmosDatabaseName" {
  description = "CosmosDB Database Name"

  type = string
}
variable "keyVaultName" {
  description = "KeyVault Name"

  type = string
}
variable "location" {
  description = "Deployment Location"

  type = string
}
variable "resourceGroupName" {
  type = string
}

variable "workspaceId" {
  description = "Log Analytics Workspace ID"

  type = string
}
variable "principalId" {
  description = "Managed Identity PrincipalId"

  type = string
}

data "azurerm_client_config" "current" {}

locals {
  dbContributor   = "00000000-0000-0000-0000-000000000002"
  dbContributorId = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resourceGroupName}/providers/Microsoft.DocumentDB/databaseAccounts/${var.cosmosAccountName}/sqlRoleDefinitions/${local.dbContributor}"
}

resource "azurerm_cosmosdb_account" "ipam" {
  name                = var.cosmosAccountName
  location            = var.location
  resource_group_name = var.resourceGroupName
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  local_authentication_disabled      = true
  automatic_failover_enabled         = true
  access_key_metadata_writes_enabled = false
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "ipam" {
  name                = var.cosmosDatabaseName
  resource_group_name = var.resourceGroupName
  account_name        = azurerm_cosmosdb_account.ipam.name
}

resource "azurerm_cosmosdb_sql_container" "ipam" {
  name                = var.cosmosContainerName
  resource_group_name = var.resourceGroupName
  account_name        = azurerm_cosmosdb_account.ipam.name
  database_name       = azurerm_cosmosdb_sql_database.ipam.name
  autoscale_settings {
    max_throughput = 1000
  }

  partition_key_path = "/tenant_id"
  # partition_key_version = 1
  indexing_policy {
    indexing_mode = "consistent"
    included_path {
      path = "/*"
    }
    # excluded_path {
    #   path = "/_etag/?"
    # }
  }
  conflict_resolution_policy {
    conflict_resolution_path = "/_ts"
    mode                     = "LastWriterWins"
  }
}

# resource "azurerm_key_vault_secret" "cosmos_key" {
#   name         = "COSMOS-KEY"
#   value        = azurerm_cosmosdb_account.ipam.primary_key
#   key_vault_id = var.keyVaultName
# }
resource "azurerm_monitor_diagnostic_setting" "ipam" {
  name               = "diagSettings"
  target_resource_id = azurerm_cosmosdb_account.ipam.id

  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id     = var.workspaceId
  enabled_log {
    category = "DataPlaneRequests"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "QueryRuntimeStatistics"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "PartitionKeyStatistics"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "PartitionKeyRUConsumption"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "ControlPlaneRequests"
    retention_policy {
      enabled = false
      days    = 0
    }
  }


  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "ipam" {
  scope               = azurerm_cosmosdb_account.ipam.id
  role_definition_id  = local.dbContributorId
  principal_id        = var.principalId
  resource_group_name = var.resourceGroupName
  account_name        = azurerm_cosmosdb_account.ipam.name
}

output "cosmosDocumentEndpoint" {
  value = azurerm_cosmosdb_account.ipam.endpoint
}
