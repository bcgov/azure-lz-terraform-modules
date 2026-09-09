#------------------------------------------------------------------------------
# Storage for Prometheus data
#------------------------------------------------------------------------------

resource "azurerm_storage_account" "prometheus" {
  name                     = "st${replace(local.resource_prefix, "-", "")}pr${random_string.suffix.result}"
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
}

resource "azurerm_storage_share" "prometheus_data" {
  name               = "prometheus-data"
  storage_account_id = azurerm_storage_account.prometheus.id
  quota              = 50
}

resource "azurerm_storage_share" "prometheus_config" {
  name               = "prometheus-config"
  storage_account_id = azurerm_storage_account.prometheus.id
  quota              = 1
}

#------------------------------------------------------------------------------
# Prometheus Configuration Files
#------------------------------------------------------------------------------

# Wait for storage account firewall rules to propagate before uploading files
resource "time_sleep" "wait_for_storage_firewall" {
  depends_on = [azurerm_storage_account.prometheus]

  create_duration = "30s"
}

# Generate prometheus.yml with Netbox IP injected
resource "local_file" "prometheus_config" {
  content = templatefile("${path.module}/shared/prometheus-config/prometheus.yml.tftpl", {
    environment = var.environment
    netbox_ip   = azurerm_container_group.netbox.ip_address
  })
  filename = "${path.module}/.generated/prometheus.yml"
}

resource "azurerm_storage_share_file" "prometheus_config" {
  name              = "prometheus.yml"
  storage_share_url = azurerm_storage_share.prometheus_config.url
  source            = local_file.prometheus_config.filename

  depends_on = [
    azurerm_storage_share.prometheus_config,
    local_file.prometheus_config,
    time_sleep.wait_for_storage_firewall
  ]
}

resource "azurerm_storage_share_file" "prometheus_alert_rules" {
  name              = "alert_rules.yml"
  storage_share_url = azurerm_storage_share.prometheus_config.url
  source            = "${path.module}/shared/prometheus-config/alert_rules.yml"

  depends_on = [
    azurerm_storage_share.prometheus_config,
    time_sleep.wait_for_storage_firewall
  ]
}

#------------------------------------------------------------------------------
# Prometheus Container Group
#------------------------------------------------------------------------------

resource "azurerm_container_group" "prometheus" {
  name                = local.prometheus_aci_name
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
  # Prometheus container
  #----------------------------------------------------------------------------
  container {
    name   = "prometheus"
    image  = var.prometheus_image
    cpu    = var.prometheus_cpu
    memory = var.prometheus_memory

    ports {
      port     = 9090
      protocol = "TCP"
    }

    # Prometheus command with retention settings
    commands = [
      "/bin/prometheus",
      "--config.file=/etc/prometheus/prometheus.yml",
      "--storage.tsdb.path=/prometheus",
      "--storage.tsdb.retention.time=${var.prometheus_retention_days}d",
      "--web.console.libraries=/usr/share/prometheus/console_libraries",
      "--web.console.templates=/usr/share/prometheus/consoles",
      "--web.enable-lifecycle"
    ]

    volume {
      name                 = "prometheus-data"
      mount_path           = "/prometheus"
      storage_account_name = azurerm_storage_account.prometheus.name
      storage_account_key  = azurerm_storage_account.prometheus.primary_access_key
      share_name           = azurerm_storage_share.prometheus_data.name
    }

    volume {
      name                 = "prometheus-config"
      mount_path           = "/etc/prometheus"
      storage_account_name = azurerm_storage_account.prometheus.name
      storage_account_key  = azurerm_storage_account.prometheus.primary_access_key
      share_name           = azurerm_storage_share.prometheus_config.name
    }

    liveness_probe {
      http_get {
        path   = "/-/healthy"
        port   = 9090
        scheme = "http"
      }
      initial_delay_seconds = 30
      period_seconds        = 15
      timeout_seconds       = 10
      failure_threshold     = 3
    }

    readiness_probe {
      http_get {
        path   = "/-/ready"
        port   = 9090
        scheme = "http"
      }
      initial_delay_seconds = 30
      period_seconds        = 10
      timeout_seconds       = 5
      failure_threshold     = 3
    }
  }

  tags = local.tags

  depends_on = [
    azurerm_subnet.containers,
    azurerm_storage_share_file.prometheus_config,
    azurerm_storage_share_file.prometheus_alert_rules
  ]
}

#------------------------------------------------------------------------------
# Diagnostic Settings for Prometheus Container Group
#------------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "prometheus" {
  name                       = "diag-${azurerm_container_group.prometheus.name}"
  target_resource_id         = azurerm_container_group.prometheus.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "ContainerInstanceLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
