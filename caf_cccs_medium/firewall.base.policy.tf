# NOTE: Resource Group is used for TLS Inspection resources (ie. Managed Identity, Key Vault), and also for the Firewall Policy objects.
resource "azurerm_resource_group" "base_firewall_policy" {
  provider = azurerm.connectivity # This is required to ensure the Resource Group is created in the correct subscription

  name     = var.resource_group_name
  location = var.primary_location
}

# NOTE: The Managed Identity, Key Vault, Key Vault Access Policy, and Certificate are only required if enabling TLS Inspection in the Firewall Policy
module "base_firewall_policy_managed_identity" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_identity/user_assigned_identity?ref=v0.0.13"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity

  location                    = var.primary_location
  resource_group_name         = azurerm_resource_group.base_firewall_policy.name
  user_assigned_identity_name = var.user_assigned_identity_name
}

module "base_firewall_policy_key_vault" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_key_vault/key_vault?ref=v0.0.13"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  key_vault_name      = var.key_vault_name
  resource_group_name = azurerm_resource_group.base_firewall_policy.name
  location            = var.primary_location

  sku_name     = var.sku_name
  network_acls = var.network_acls

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  public_network_access_enabled   = var.public_network_access_enabled
}

# IMPORTANT: Although using Azure RBAC is the preferred/recommended approach to grant access to the Key Vault,
# according to the following documentation (https://learn.microsoft.com/en-us/azure/firewall/premium-certificates#azure-key-vault),
# Azure role-based access control (Azure RBAC) is not currently supported for authorization, and we need to use the access policy model instead.

# NOTE: If executing/testing locally, the first apply will fail due to your account not having access to the Key Vault.
# Manually add your account with the Certificate "Get" and "List" permissions to the Key Vault Access Policy, and re-run the apply.
module "base_firewall_policy_key_vault_access_policy" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_key_vault/key_vault_access_policy?ref=v0.0.13"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  key_vault_id   = module.base_firewall_policy_key_vault.key_vault_id
  object_id      = module.base_firewall_policy_managed_identity.principal_id
  application_id = var.application_id

  certificate_permissions = var.certificate_permissions
  key_permissions         = var.key_permissions
  secret_permissions      = var.secret_permissions
  storage_permissions     = var.storage_permissions
}

module "base_firewall_policy_key_vault_certificate" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_key_vault/key_vault_certificate?ref=v0.0.13"

  providers = {
    azurerm = azurerm.connectivity
  }

  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  # NOTE: The certificiate here is a self-signed certificate as a placeholder to enable TLS Inspection in the Firewall Policy
  certificate_name = var.certificate_name
  key_vault_id     = module.base_firewall_policy_key_vault.key_vault_id
  certificate      = var.certificate
}

resource "azurerm_firewall_policy" "base_firewall_policy" {
  provider = azurerm.connectivity # This is required to ensure the Resource Group is created in the correct subscription

  name                = var.base_firewall_policy_name
  resource_group_name = azurerm_resource_group.base_firewall_policy.name
  location            = var.primary_location
  sku                 = var.sku
  
  intrusion_detection {
    mode = var.intrusion_detection.mode

    traffic_bypass {
      
      name = var.intrusion_detection.traffic_bypass.name
      description = var.intrusion_detection.traffic_bypass.description
      protocol = var.intrusion_detection.traffic_bypass.protocol
      destination_addresses = var.intrusion_detection.traffic_bypass.destination_addresses
      destination_ports = var.intrusion_detection.traffic_bypass.destination_ports
      source_addresses = var.intrusion_detection.traffic_bypass.source_addresses
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
    ignore_changes = all
  }
}
