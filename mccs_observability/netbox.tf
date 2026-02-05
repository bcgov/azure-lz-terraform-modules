#------------------------------------------------------------------------------
# Storage for Netbox media files
#------------------------------------------------------------------------------

resource "azurerm_storage_account" "netbox" {
  name                     = "st${replace(local.resource_prefix, "-", "")}nb${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Restrict to VNet access only
  public_network_access_enabled   = true # Required for VNet service endpoint access
  allow_nested_items_to_be_public = false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.containers.id]
    ip_rules                   = var.allowed_ip_addresses
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_storage_share" "netbox_media" {
  name               = "netbox-media"
  storage_account_id = azurerm_storage_account.netbox.id
  quota              = 5
}

#------------------------------------------------------------------------------
# Netbox Container Group
#------------------------------------------------------------------------------

resource "azurerm_container_group" "netbox" {
  name                = local.netbox_aci_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Linux"
  ip_address_type     = "Private"
  subnet_ids          = [azurerm_subnet.containers.id]

  # ACI does NOT inherit VNet DNS settings - must be explicitly configured
  # Without this, containers use Azure DNS (168.63.129.16) and cannot resolve
  # private DNS zone hostnames routed through the firewall
  dynamic "dns_config" {
    for_each = length(var.dns_servers) > 0 ? [1] : []
    content {
      nameservers = var.dns_servers
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aci.id]
  }

  #----------------------------------------------------------------------------
  # Netbox container
  #----------------------------------------------------------------------------
  container {
    name   = "netbox"
    image  = var.netbox_image
    cpu    = var.netbox_cpu
    memory = var.netbox_memory

    ports {
      port     = 8080
      protocol = "TCP"
    }

    environment_variables = {
      # Set HOME to /opt/netbox to avoid permission errors with /root/.postgresql/postgresql.crt
      HOME = "/opt/netbox"

      # Database connection
      DB_HOST    = azurerm_postgresql_flexible_server.this.fqdn
      DB_NAME    = local.postgresql_database_name
      DB_USER    = var.postgresql_admin_username
      DB_PORT    = "5432"
      DB_SSLMODE = "require"

      # Redis connection (sidecar)
      REDIS_HOST            = "localhost"
      REDIS_PORT            = "6379"
      REDIS_CACHE_DATABASE  = "0"
      REDIS_DEFAULT_TIMEOUT = "300"

      # Netbox configuration
      SUPERUSER_NAME       = "admin"
      SUPERUSER_EMAIL      = var.netbox_admin_email
      ALLOWED_HOSTS        = "*"
      SKIP_STARTUP_SCRIPTS = "false"

      # Metrics endpoint for Prometheus (built-in django-prometheus)
      METRICS_ENABLED = "true"
    }

    secure_environment_variables = {
      DB_PASSWORD         = random_password.postgresql_admin.result
      SECRET_KEY          = random_password.netbox_secret_key.result
      SUPERUSER_PASSWORD  = random_password.netbox_admin.result
      SUPERUSER_API_TOKEN = random_password.netbox_api_token.result
    }

    volume {
      name                 = "netbox-media"
      mount_path           = "/opt/netbox/netbox/media"
      storage_account_name = azurerm_storage_account.netbox.name
      storage_account_key  = azurerm_storage_account.netbox.primary_access_key
      share_name           = azurerm_storage_share.netbox_media.name
    }

    liveness_probe {
      http_get {
        path   = "/api/"
        port   = 8080
        scheme = "http"
      }
      initial_delay_seconds = 120
      period_seconds        = 30
      timeout_seconds       = 10
      failure_threshold     = 5
    }

    readiness_probe {
      http_get {
        path   = "/api/"
        port   = 8080
        scheme = "http"
      }
      initial_delay_seconds = 60
      period_seconds        = 10
      timeout_seconds       = 5
      failure_threshold     = 3
    }
  }

  #----------------------------------------------------------------------------
  # Redis sidecar container
  #----------------------------------------------------------------------------
  container {
    name   = "redis"
    image  = var.redis_image
    cpu    = 0.25
    memory = 0.5

    ports {
      port     = 6379
      protocol = "TCP"
    }

    commands = ["redis-server", "--appendonly", "yes"]

    # Note: ACI liveness probes only support http_get, not exec commands
    # Redis health is monitored via container restart policy
  }

  tags = local.tags

  depends_on = [
    azurerm_postgresql_flexible_server_database.netbox,
    azurerm_subnet.containers
  ]

  lifecycle {
    ignore_changes = [tags]
  }
}

#------------------------------------------------------------------------------
# Diagnostic Settings for Netbox Container Group
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "netbox" {
  name                       = "diag-${azurerm_container_group.netbox.name}"
  target_resource_id         = azurerm_container_group.netbox.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "ContainerInstanceLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
