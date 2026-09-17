# NOTE: Resource Group is used for TLS Inspection resources (ie. Managed Identity, Key Vault), and also for the Firewall Policy objects.
resource "azurerm_resource_group" "base_firewall_policy" {
  provider = azurerm.connectivity # This is required to ensure the Resource Group is created in the correct subscription

  name     = var.fw_base_config.resource_group_name
  location = var.location
}

# NOTE: The Managed Identity, Key Vault, Key Vault Access Policy, and Certificate are only required if enabling TLS Inspection in the Firewall Policy
module "base_firewall_policy_managed_identity" {
  source = "../azure_identity/user_assigned_identity"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  location                    = var.location
  resource_group_name         = azurerm_resource_group.base_firewall_policy.name
  user_assigned_identity_name = var.fw_base_config.tls_inspection_user_assigned_identity_name
}

module "base_firewall_policy_key_vault" {
  source = "../azure_key_vault/key_vault"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  key_vault_name      = var.fw_base_config.tls_inspection_key_vault_name
  resource_group_name = azurerm_resource_group.base_firewall_policy.name
  location            = var.location

  sku_name     = var.fw_base_config.tls_inspection_sku_name
  network_acls = null

  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = var.fw_base_config.tls_inspection_enable_rbac_authorization
  public_network_access_enabled   = var.fw_base_config.tls_inspection_public_network_access_enabled
}

# IMPORTANT: Although using Azure RBAC is the preferred/recommended approach to grant access to the Key Vault,
# according to the following documentation (https://learn.microsoft.com/en-us/azure/firewall/premium-certificates#azure-key-vault),
# Azure role-based access control (Azure RBAC) is not currently supported for authorization, and we need to use the access policy model instead.

# NOTE: If executing/testing locally, the first apply will fail due to your account not having access to the Key Vault.
# Manually add your account with the Certificate "Get" and "List" permissions to the Key Vault Access Policy, and re-run the apply.
module "base_firewall_policy_key_vault_access_policy" {
  source = "../azure_key_vault/key_vault_access_policy"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  key_vault_id   = module.base_firewall_policy_key_vault.key_vault_id
  object_id      = module.base_firewall_policy_managed_identity.principal_id
  application_id = null

  certificate_permissions = []
  key_permissions         = []
  secret_permissions      = var.fw_base_config.tls_inspection_secret_permissions
  storage_permissions     = []
}

module "base_firewall_policy_key_vault_certificate" {
  source = "../azure_key_vault/key_vault_certificate"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  # NOTE: The certificiate here is a self-signed certificate as a placeholder to enable TLS Inspection in the Firewall Policy
  certificate_name = var.fw_base_config.tls_inspection_certificate_name
  key_vault_id     = module.base_firewall_policy_key_vault.key_vault_id
  certificate      = var.fw_base_config.tls_inspection_certificate
}

resource "azurerm_firewall_policy" "base_firewall_policy" {
  provider = azurerm.connectivity # This is required to ensure the Resource Group is created in the correct subscription

  name                = var.fw_base_config.policy_name
  resource_group_name = azurerm_resource_group.base_firewall_policy.name
  location            = var.location
  sku                 = var.fw_base_config.sku

  dynamic "intrusion_detection" {
    for_each = var.fw_base_config.intrusion_detection != null ? [var.fw_base_config.intrusion_detection] : []

    content {
      mode = intrusion_detection.value.mode

      dynamic "traffic_bypass" {
        for_each = intrusion_detection.value.traffic_bypass
        content {
          name                  = traffic_bypass.value.name
          description           = traffic_bypass.value.description
          protocol              = traffic_bypass.value.protocol
          destination_addresses = traffic_bypass.value.destination_addresses
          destination_ip_groups = traffic_bypass.value.destination_ip_groups
          destination_ports     = traffic_bypass.value.destination_ports
          source_addresses      = traffic_bypass.value.source_addresses
          source_ip_groups      = traffic_bypass.value.source_ip_groups
        }
      }
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      "${module.base_firewall_policy_managed_identity.user_assigned_identity_id}"
    ]
  }

  # NOTE: The certificiate here is a self-signed certificate as a placeholder to enable TLS Inspection in the Firewall Policy
  tls_certificate {
    name                = module.base_firewall_policy_key_vault_certificate.key_vault_certificate_name
    key_vault_secret_id = module.base_firewall_policy_key_vault_certificate.key_vault_secret_id
  }

  lifecycle {
    ignore_changes = [
      private_ip_ranges,
      insights,
      intrusion_detection,
      threat_intelligence_allowlist,
      tags
    ]
  }
}
