#------------------------------------------------------------------------------
# MCCS Observability Platform - Connectivity Environment
#
# This example shows how to deploy the MCCS Observability Platform
# in the BC Gov Connectivity subscription.
#------------------------------------------------------------------------------

module "mccs_observability" {
  source = "../../"

  providers = {
    azurerm            = azurerm
    azurerm.management = azurerm.management
  }

  # Environment configuration
  environment = var.environment
  location    = var.location

  # Subscription IDs
  subscription_id_connectivity = var.subscription_id_connectivity
  subscription_id_management   = var.subscription_id_management

  # Networking - IPAM allocates address space for the VNet
  use_ipam                     = var.use_ipam
  network_manager_ipam_pool_id = var.network_manager_ipam_pool_id

  # Static address space - Only used when use_ipam is false
  vnet_address_space = var.vnet_address_space

  # Virtual WAN Hub Connection
  virtual_hub_id            = var.virtual_hub_id
  internet_security_enabled = var.internet_security_enabled

  # Private DNS Zones for Private Endpoints
  central_postgresql_dns_zone_id = var.central_postgresql_dns_zone_id
  central_keyvault_dns_zone_id   = var.central_keyvault_dns_zone_id
  central_grafana_dns_zone_id    = var.central_grafana_dns_zone_id
  create_private_dns_zone_groups = false # Using DINE policy

  # Identity
  cloud_team_group_name   = var.cloud_team_group_name
  noc_team_group_id       = var.noc_team_group_id
  service_desk_group_id   = var.service_desk_group_id
  terraform_spn_object_id = var.terraform_spn_object_id

  # ExpressRoute circuits to monitor
  expressroute_circuits = var.expressroute_circuits
  expressroute_gateways = var.expressroute_gateways

  # Alerting configuration
  enable_alerting   = var.enable_alerting
  teams_webhook_url = var.teams_webhook_url
  cloud_team_email  = var.cloud_team_email
  jira_base_url     = var.jira_base_url
  jira_user_email   = var.jira_user_email
  jira_api_token    = var.jira_api_token
  jira_project_key  = var.jira_project_key

  # Component configuration
  netbox_admin_email = var.netbox_admin_email

  # Tags
  tags = var.tags
}
