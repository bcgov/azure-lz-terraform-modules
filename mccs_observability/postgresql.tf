#------------------------------------------------------------------------------
# PostgreSQL Flexible Server
#------------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server" "this" {
  name                = "${local.postgresql_server_name}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  version             = var.postgresql_version

  # Compute and storage
  sku_name   = var.postgresql_sku_name
  storage_mb = var.postgresql_storage_mb

  # Authentication
  administrator_login    = var.postgresql_admin_username
  administrator_password = random_password.postgresql_admin.result

  # Networking - VNet integration
  delegated_subnet_id = azurerm_subnet.postgresql.id
  private_dns_zone_id = var.central_postgresql_dns_zone_id

  # Backup configuration
  backup_retention_days        = var.postgresql_backup_retention_days
  geo_redundant_backup_enabled = var.postgresql_geo_redundant_backup

  # High availability configuration
  dynamic "high_availability" {
    for_each = var.postgresql_high_availability ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }

  # Primary zone
  zone = "1"

  tags = local.tags

  lifecycle {
    ignore_changes = [
      tags,
      # Ignore password changes after initial creation
      administrator_password
    ]
  }

  depends_on = [
    azurerm_subnet.postgresql
  ]
}

#------------------------------------------------------------------------------
# PostgreSQL Database for Netbox
#------------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_database" "netbox" {
  name      = local.postgresql_database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

#------------------------------------------------------------------------------
# PostgreSQL Firewall Rules
# Note: With VNet integration, no firewall rules are typically needed
# as access is controlled by VNet/subnet
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# PostgreSQL Server Parameters
#------------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_disconnections" {
  name      = "log_disconnections"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "connection_throttling" {
  name      = "connection_throttle.enable"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

#------------------------------------------------------------------------------
# Diagnostic Settings for PostgreSQL
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  name                       = "diag-${azurerm_postgresql_flexible_server.this.name}"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_log {
    category = "PostgreSQLFlexSessions"
  }

  enabled_log {
    category = "PostgreSQLFlexQueryStoreRuntime"
  }

  enabled_log {
    category = "PostgreSQLFlexQueryStoreWaitStats"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
