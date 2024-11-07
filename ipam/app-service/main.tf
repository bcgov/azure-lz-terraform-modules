variable "appServiceName" {
  description = "App Service Name"
  type        = string
}

variable "appServicePlanName" {
  description = "App Service Plan Name"
  type        = string
}

variable "cosmosDbUri" {
  description = "CosmosDB URI"
  type        = string
}

variable "databaseName" {
  description = "CosmosDB Database Name"
  type        = string
}

variable "containerName" {
  description = "CosmosDB Container Name"
  type        = string
}

variable "keyVaultUri" {
  description = "KeyVault URI"
  type        = string
}

variable "location" {
  description = "Deployment Location"
  type        = string
}

variable "azureCloud" {
  description = "Azure Cloud Enviroment"
  type        = string
  default     = "AZURE_PUBLIC"
}

variable "managedIdentityId" {
  description = "Managed Identity Id"
  type        = string
}

variable "managedIdentityClientId" {
  description = "Managed Identity ClientId"
  type        = string
}

variable "workspaceId" {
  description = "Log Analytics Worskpace ID"
  type        = string
}

variable "deployAsContainer" {
  type        = bool
  default     = false
  description = "Flag to Deploy IPAM as a Container"
}

variable "privateAcr" {
  type        = bool
  default     = false
  description = "Flag to Deploy Private Container Registry"
}

variable "privateAcrUri" {
  description = "Uri for Private Container Registry"
  type        = string
}

variable "resourceGroupName" {
  type = string
}

locals {
  acrUri        = var.privateAcr ? var.privateAcrUri : "https://azureipam.azurecr.io"
  runtime_image = "ipam:3.4.0"
}

resource "azurerm_service_plan" "ipam" {
  name                = var.appServicePlanName
  resource_group_name = var.resourceGroupName
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v3"
  worker_count        = 1
}
resource "azurerm_linux_web_app" "ipam" {
  name                            = var.appServiceName
  resource_group_name             = var.resourceGroupName
  location                        = var.location
  service_plan_id                 = azurerm_service_plan.ipam.id
  key_vault_reference_identity_id = var.managedIdentityId
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managedIdentityId]
  }
  site_config {
    ftps_state        = "Disabled"
    health_check_path = "/api/status"
    # ip_restriction_default_action     = "Allow"
    # scm_ip_restriction_default_action = "Allow"
    application_stack {
      docker_registry_url = local.acrUri
      docker_image_name   = local.runtime_image
    }
    use_32_bit_worker = false
  }
  https_only              = true
  client_affinity_enabled = true
  app_settings = {
    AZURE_ENV : var.azureCloud,
    COSMOS_URL : var.cosmosDbUri,
    DATABASE_NAME : var.databaseName,
    CONTAINER_NAME : var.containerName
    MANAGED_IDENTITY_ID : "@Microsoft.KeyVault(SecretUri=${var.keyVaultUri}secrets/IDENTITY-ID/)",
    UI_APP_ID : "@Microsoft.KeyVault(SecretUri=${var.keyVaultUri}secrets/UI-ID/)",
    ENGINE_APP_ID : "@Microsoft.KeyVault(SecretUri=${var.keyVaultUri}secrets/ENGINE-ID/)",
    ENGINE_APP_SECRET : "@Microsoft.KeyVault(SecretUri=${var.keyVaultUri}secrets/ENGINE-SECRET/)",
    TENANT_ID : "@Microsoft.KeyVault(SecretUri=${var.keyVaultUri}secrets/TENANT-ID/)",
    KEYVAULT_URL : var.keyVaultUri,
    # WEBSITE_HEALTHCHECK_MAXPINGFAILURES : "2",
  }
  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 50
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "ipam-service-plan" {
  name                       = "diagSettings"
  target_resource_id         = azurerm_service_plan.ipam.id
  log_analytics_workspace_id = var.workspaceId
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
      days    = 0
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "ipam-service" {
  name               = "diagSettings"
  target_resource_id = azurerm_linux_web_app.ipam.id

  log_analytics_workspace_id = var.workspaceId
  enabled_log {
    category = "AppServiceAntivirusScanAuditLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "AppServiceHTTPLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "AppServiceConsoleLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "AppServiceAppLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "AppServiceFileAuditLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "AppServiceAuditLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "AppServiceIPSecAuditLogs"
    retention_policy {
      enabled = false
      days    = 0
    }
  }
  enabled_log {
    category = "AppServicePlatformLogs"
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

# output "appServiceHostName"{
# value = appService.properties.defaultHostName
# }
