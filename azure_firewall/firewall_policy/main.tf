resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_firewall_policy" "this" {
  name                = var.firewall_policy_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  base_policy_id = var.base_policy_id

  dynamic "dns" {
    for_each = var.dns != null ? [var.dns] : []
    content {
      proxy_enabled = dns.value.proxy_enabled
      servers       = dns.value.servers
    }    
  }

  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }    
  }

  dynamic "insights" {
    for_each = var.insights != null ? [var.insights] : []
    content {
      enabled                        = insights.value.enabled
      default_log_analytics_workspace_id = insights.value.default_log_analytics_workspace_id
      retention_in_days                 = insights.value.retention_in_days

      dynamic "log_analytics_workspace" {
        for_each = insights.value.log_analytics_workspace != null ? [insights.value.log_analytics_workspace] : []
        content {
          id                = log_analytics_workspace.value.id
          firewall_location = log_analytics_workspace.value.firewall_location
        }
      }
    }
  }

  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection != null ? [var.intrusion_detection] : []
    content {
      mode = intrusion_detection.value.mode

      dynamic "signature_overrides" {
        for_each = intrusion_detection.value.signature_overrides != null ? [intrusion_detection.value.signature_overrides] : []
        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }
    }
  }

  private_ip_ranges = var.private_ip_ranges
  auto_learn_private_ranges_enabled = var.auto_learn_private_ranges_enabled
  sku = var.sku
  tags = var.tags

  dynamic "threat_intelligence_allowlist" {
    for_each = var.threat_intelligence_allowlist != null ? [var.threat_intelligence_allowlist] : []
    content {
      ip_addresses = threat_intelligence_allowlist.value.ip_addresses
    }    
  }

  threat_intelligence_mode = var.threat_intelligence_mode
  dynamic "tls_certificate" {
    for_each = var.tls_certificate != null ? [var.tls_certificate] : []
    content {
      key_vault_secret_id = tls_certificate.value.key_vault_secret_id
      name = tls_certificate.value.name
    }        
  }

  sql_redirect_allowed = var.sql_redirect_allowed
  dynamic "explicit_proxy" {
    for_each = var.explicit_proxy != null ? [var.explicit_proxy] : []
    content {
      enabled = explicit_proxy.value.enabled
    }        
  }
}