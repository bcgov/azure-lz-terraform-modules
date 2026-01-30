# MCCS Observability Platform

This Terraform module deploys the **Multi-Cloud Connectivity Service (MCCS) Observability Platform** - a unified monitoring solution for BC Government's hybrid cloud connectivity infrastructure.

## Overview

The MCCS Observability Platform provides:

- **Single Pane of Glass**: Consolidated view of all MCCS connections across Azure ExpressRoute (and AWS Direct Connect in Phase 2)
- **Proactive Monitoring**: Real-time alerting on connectivity issues before user impact
- **Rapid Troubleshooting**: Centralized diagnostics to reduce mean time to resolution (MTTR)
- **Network Documentation**: Authoritative source of truth for circuit inventory and topology via Netbox

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MCCS OBSERVABILITY PLATFORM                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Data Sources          Collection & Storage           Visualization         │
│  ─────────────         ──────────────────────         ─────────────         │
│  ExpressRoute    ───►  Log Analytics Workspace  ───►  Azure Managed         │
│  Circuits              Prometheus (ACI)               Grafana               │
│  Gateways              PostgreSQL Flexible                                  │
│                        Server (Netbox DB)                                   │
│                                                                             │
│  Alerting                        Secrets                                    │
│  ────────                        ───────                                    │
│  Logic App ───► Teams            Key Vault                                  │
│           ───► Jira JSM          (RBAC-enabled)                             │
│                                                                             │
│  Network Source of Truth                                                    │
│  ───────────────────────                                                    │
│  Netbox (ACI) - Circuit Records, Provider Info, IP Management               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Components

| Component | Description |
|-----------|-------------|
| **Azure Managed Grafana** | Visualization and dashboards with Entra ID authentication |
| **PostgreSQL Flexible Server** | Zone-redundant database for Netbox |
| **Netbox (ACI)** | Network source of truth for circuit inventory |
| **Prometheus (ACI)** | Metrics collection for Netbox data and Phase 2 AWS |
| **Log Analytics Workspace** | Diagnostic data storage |
| **Key Vault** | Secrets management with RBAC |
| **Logic App** | Alert routing to Teams and Jira JSM |
| **Alert Rules** | ExpressRoute BGP/ARP availability, bandwidth utilization |

## Prerequisites

- Azure subscription with Contributor access
- Existing hub VNet for subnet deployment
- CAF Enterprise Scale Private DNS Zones (or DINE policies)
- Entra ID groups for RBAC
- ExpressRoute circuits and gateways already provisioned
- Teams webhook URL
- Jira API token for incident creation

## Usage

### With IPAM (Recommended)

The module creates a dedicated VNet with address space allocated from IPAM, split into /26 subnets.

```hcl
module "mccs_observability" {
  source = "github.com/bcgov/azure-lz-terraform-modules//mccs_observability"

  # Environment
  environment = "prod"
  location    = "canadacentral"

  # IPAM - allocates /24 for VNet, splits into /26 subnets
  use_ipam                     = true
  network_manager_ipam_pool_id = "/subscriptions/.../providers/Microsoft.Network/networkManagers/.../ipamPools/..."

  # Private DNS Zone (CAF Central)
  central_postgresql_dns_zone_id = "/subscriptions/.../privatelink.postgres.database.azure.com"

  # Identity
  cloud_team_group_id = "00000000-0000-0000-0000-000000000000"

  # ExpressRoute circuits to monitor
  expressroute_circuits = {
    "er-kamloops-01" = {
      circuit_name        = "er-kamloops-primary"
      resource_group_name = "rg-connectivity"
      bandwidth_mbps      = 1000
      location            = "Kamloops DC"
      provider_name       = "Telus"
    }
  }

  # Alerting
  teams_webhook_url  = var.teams_webhook_url
  cloud_team_email   = "cloud-team@gov.bc.ca"
  jira_base_url      = "https://bcgov.atlassian.net"
  jira_user_email    = "automation@gov.bc.ca"
  jira_api_token     = var.jira_api_token
  jira_project_key   = "MCCS"

  # Netbox
  netbox_admin_email = "cloud-team@gov.bc.ca"
}
```

### With Static Address Space

For environments without IPAM, provide a static /24 address space.

```hcl
module "mccs_observability" {
  source = "github.com/bcgov/azure-lz-terraform-modules//mccs_observability"

  # Environment
  environment = "prod"
  location    = "canadacentral"

  # Static address space - will be split into /26 subnets
  use_ipam           = false
  vnet_address_space = "10.100.0.0/24"

  # ... rest of configuration
}
```

## Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `environment` | Environment name (prod, dev, staging, test) | `string` |
| `central_postgresql_dns_zone_id` | CAF central PostgreSQL DNS zone ID | `string` |
| `cloud_team_group_id` | Entra ID group for Cloud Team | `string` |
| `expressroute_circuits` | Map of ExpressRoute circuits to monitor | `map(object)` |
| `teams_webhook_url` | Microsoft Teams webhook URL | `string` |
| `cloud_team_email` | Cloud team email for alerts | `string` |
| `jira_base_url` | Jira instance base URL | `string` |
| `jira_user_email` | Jira API user email | `string` |
| `jira_api_token` | Jira API token | `string` |

### Networking / IPAM Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `use_ipam` | Whether to use Azure Network Manager IPAM | `bool` | `true` |
| `network_manager_ipam_pool_id` | IPAM Pool ID (required when use_ipam=true) | `string` | `null` |
| `vnet_address_space` | VNet address space /24 (required when use_ipam=false) | `string` | `null` |
| `vnet_name` | Override for VNet name | `string` | `null` |
| `jira_project_key` | Jira project key | `string` |
| `netbox_admin_email` | Netbox admin email | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `location` | Azure region | `string` | `"canadacentral"` |
| `noc_team_group_id` | Entra ID group for NOC Team | `string` | `null` |
| `service_desk_group_id` | Entra ID group for Service Desk | `string` | `null` |
| `enable_alerting` | Enable alerting infrastructure | `bool` | `true` |
| `grafana_sku` | Grafana SKU (Standard/Essential) | `string` | `"Standard"` |
| `postgresql_high_availability` | Enable PostgreSQL HA | `bool` | `true` |
| `tags` | Additional resource tags | `map(string)` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| `resource_group_name` | The name of the resource group |
| `grafana_endpoint` | The Grafana endpoint URL |
| `netbox_private_ip` | The private IP of the Netbox container |
| `prometheus_private_ip` | The private IP of the Prometheus container |
| `postgresql_fqdn` | The PostgreSQL server FQDN |
| `key_vault_uri` | The Key Vault URI |
| `log_analytics_workspace_id` | The Log Analytics Workspace ID |

## Post-Deployment Steps

### 1. Upload Prometheus Configuration

```bash
az storage file upload \
  --account-name <storage-account-name> \
  --share-name prometheus-config \
  --source shared/prometheus-config/prometheus.yml \
  --path prometheus.yml
```

### 2. Configure Netbox API Token

After Netbox is running, create an API token for the Prometheus exporter:

1. Access Netbox at `http://<netbox-private-ip>:8080`
2. Login with admin credentials (from Key Vault)
3. Navigate to Admin → API Tokens
4. Create a new token
5. Update the `netbox-exporter` container with the token

### 3. Populate Netbox Inventory

Use the Netbox API or UI to add:

- Sites (Kamloops DC, Calgary DC)
- Providers (Telus, Shaw, AWS)
- Circuits (ExpressRoute and Direct Connect)
- IP addressing information

### 4. Verify Grafana Data Sources

1. Access Grafana via the private endpoint
2. Verify Azure Monitor data source is connected
3. Add Prometheus data source pointing to `http://<prometheus-ip>:9090`
4. Import or create dashboards

## Alert Definitions

| Alert | Condition | Severity | Notification |
|-------|-----------|----------|--------------|
| BGP Availability Down | < 100% for 5 min | Sev0 (Critical) | Teams + Jira |
| ARP Availability Down | < 100% for 5 min | Sev0 (Critical) | Teams + Jira |
| Bandwidth High | > 80% for 15 min | Sev2 (Warning) | Teams |
| Bandwidth Critical | > 95% for 5 min | Sev1 (Error) | Teams |
| Gateway Unhealthy | Unhealthy state | Sev0 (Critical) | Teams + Jira |

## Security

- All resources use private endpoints (no public access)
- Entra ID authentication for Grafana
- Key Vault with RBAC for secrets
- Network Security Groups on subnets
- TLS 1.2+ enforced

## Phase 2: AWS Direct Connect

Future enhancements will include:

- AWS Direct Connect monitoring via CloudWatch metrics proxy
- Cross-cloud correlation dashboards
- Unified alerting across Azure and AWS

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_azurerm.management"></a> [azurerm.management](#provider\_azurerm.management) | ~> 4.0 |
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_group.netbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_container_group.prometheus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_dashboard_grafana.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dashboard_grafana) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.jira_api_token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.netbox_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.netbox_api_token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.netbox_secret_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.postgresql_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.teams_webhook_url](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_log_analytics_solution.container_insights](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_logic_app_action_custom.parse_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_trigger_http_request.alert_trigger](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_trigger_http_request) | resource |
| [azurerm_logic_app_workflow.alert_router](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_workflow) | resource |
| [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_activity_log_alert.resource_health](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert) | resource |
| [azurerm_monitor_diagnostic_setting.expressroute_circuits](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.expressroute_gateways](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.grafana](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.log_analytics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.logic_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.netbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.prometheus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_netbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_prometheus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.arp_availability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.bandwidth_critical](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.bandwidth_warning](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.bgp_availability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.gateway_health](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_workspace) | resource |
| [azurerm_network_manager_ipam_pool_static_cidr.mccs_observability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_ipam_pool_static_cidr) | resource |
| [azurerm_network_security_group.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.connection_throttling](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_configuration.log_connections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_configuration.log_disconnections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_database.netbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_private_endpoint.grafana](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aci_keyvault_secrets_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aci_storage_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cloud_team_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cloud_team_grafana_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cloud_team_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_expressroute_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_gateway_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_log_analytics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_monitoring_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.logic_app_secrets_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.noc_team_grafana_editor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.service_desk_grafana_viewer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.terraform_spn_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.netbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account.prometheus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_share.netbox_media](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_share.prometheus_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_share.prometheus_data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_share_file.prometheus_alert_rules](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_file) | resource |
| [azurerm_storage_share_file.prometheus_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share_file) | resource |
| [azurerm_subnet.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.postgresql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_user_assigned_identity.aci](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_hub_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [local_file.prometheus_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.netbox_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.netbox_api_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.netbox_secret_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.postgresql_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_express_route_circuit.circuits](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/express_route_circuit) | data source |
| [azurerm_virtual_network_gateway.gateways](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network_gateway) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | Override for the Action Group name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_alert_evaluation_frequency"></a> [alert\_evaluation\_frequency](#input\_alert\_evaluation\_frequency) | How often alert rules are evaluated. | `string` | `"PT5M"` | no |
| <a name="input_alert_window_size"></a> [alert\_window\_size](#input\_alert\_window\_size) | The time window for alert evaluation. | `string` | `"PT5M"` | no |
| <a name="input_allowed_ip_addresses"></a> [allowed\_ip\_addresses](#input\_allowed\_ip\_addresses) | List of IP addresses or CIDR ranges allowed to access Key Vault and Storage Accounts through public endpoints. Used for Terraform runners or admin access. | `list(string)` | `[]` | no |
| <a name="input_arp_availability_threshold"></a> [arp\_availability\_threshold](#input\_arp\_availability\_threshold) | ARP availability percentage threshold for critical alerts. | `number` | `100` | no |
| <a name="input_bandwidth_critical_threshold"></a> [bandwidth\_critical\_threshold](#input\_bandwidth\_critical\_threshold) | Bandwidth utilization percentage threshold for critical alerts. | `number` | `95` | no |
| <a name="input_bandwidth_warning_threshold"></a> [bandwidth\_warning\_threshold](#input\_bandwidth\_warning\_threshold) | Bandwidth utilization percentage threshold for warning alerts. | `number` | `80` | no |
| <a name="input_bgp_availability_threshold"></a> [bgp\_availability\_threshold](#input\_bgp\_availability\_threshold) | BGP availability percentage threshold for critical alerts. | `number` | `100` | no |
| <a name="input_central_grafana_dns_zone_id"></a> [central\_grafana\_dns\_zone\_id](#input\_central\_grafana\_dns\_zone\_id) | The resource ID of the central Private DNS Zone for Grafana (privatelink.grafana.azure.com). | `string` | `null` | no |
| <a name="input_central_keyvault_dns_zone_id"></a> [central\_keyvault\_dns\_zone\_id](#input\_central\_keyvault\_dns\_zone\_id) | The resource ID of the central Private DNS Zone for Key Vault (privatelink.vaultcore.azure.net). | `string` | `null` | no |
| <a name="input_central_postgresql_dns_zone_id"></a> [central\_postgresql\_dns\_zone\_id](#input\_central\_postgresql\_dns\_zone\_id) | The resource ID of the central Private DNS Zone for PostgreSQL (privatelink.postgres.database.azure.com). | `string` | n/a | yes |
| <a name="input_cloud_team_email"></a> [cloud\_team\_email](#input\_cloud\_team\_email) | The email address for the Cloud Team (fallback for alerts). | `string` | n/a | yes |
| <a name="input_cloud_team_group_id"></a> [cloud\_team\_group\_id](#input\_cloud\_team\_group\_id) | The Object ID of the Entra ID group for the Cloud Team (Grafana Admin, Key Vault Secrets Officer). | `string` | n/a | yes |
| <a name="input_create_private_dns_zone_groups"></a> [create\_private\_dns\_zone\_groups](#input\_create\_private\_dns\_zone\_groups) | Whether to create private DNS zone groups for private endpoints. Set to false if using DINE policies. | `bool` | `false` | no |
| <a name="input_diagnostics_retention_days"></a> [diagnostics\_retention\_days](#input\_diagnostics\_retention\_days) | Number of days to retain diagnostic logs. Set to 0 for unlimited retention. | `number` | `90` | no |
| <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting) | Whether to enable alerting infrastructure (Action Groups, Alert Rules, Logic App). | `bool` | `true` | no |
| <a name="input_enable_expressroute_diagnostics"></a> [enable\_expressroute\_diagnostics](#input\_enable\_expressroute\_diagnostics) | Whether to enable diagnostic settings on ExpressRoute circuits and gateways. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name (e.g., prod, dev, staging). | `string` | n/a | yes |
| <a name="input_expressroute_circuits"></a> [expressroute\_circuits](#input\_expressroute\_circuits) | Map of ExpressRoute circuits to monitor. | <pre>map(object({<br/>    circuit_name        = string<br/>    resource_group_name = string<br/>    bandwidth_mbps      = number<br/>    location            = string<br/>    provider_name       = optional(string, "Unknown")<br/>  }))</pre> | n/a | yes |
| <a name="input_expressroute_gateways"></a> [expressroute\_gateways](#input\_expressroute\_gateways) | Map of ExpressRoute gateways to monitor. | <pre>map(object({<br/>    gateway_name        = string<br/>    resource_group_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_grafana_api_key_enabled"></a> [grafana\_api\_key\_enabled](#input\_grafana\_api\_key\_enabled) | Whether to enable API key authentication for Grafana. | `bool` | `true` | no |
| <a name="input_grafana_deterministic_outbound_ip"></a> [grafana\_deterministic\_outbound\_ip](#input\_grafana\_deterministic\_outbound\_ip) | Whether to enable deterministic outbound IP for Grafana. | `bool` | `true` | no |
| <a name="input_grafana_name"></a> [grafana\_name](#input\_grafana\_name) | Override for the Azure Managed Grafana name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_grafana_public_network_access"></a> [grafana\_public\_network\_access](#input\_grafana\_public\_network\_access) | Whether to enable public network access to Grafana. | `bool` | `false` | no |
| <a name="input_grafana_sku"></a> [grafana\_sku](#input\_grafana\_sku) | The SKU for Azure Managed Grafana. | `string` | `"Standard"` | no |
| <a name="input_grafana_zone_redundancy"></a> [grafana\_zone\_redundancy](#input\_grafana\_zone\_redundancy) | Whether to enable zone redundancy for Grafana. | `bool` | `true` | no |
| <a name="input_internet_security_enabled"></a> [internet\_security\_enabled](#input\_internet\_security\_enabled) | Whether to enable internet security (route internet traffic through the hub firewall). | `bool` | `true` | no |
| <a name="input_jira_api_token"></a> [jira\_api\_token](#input\_jira\_api\_token) | The Jira API token for authentication. | `string` | n/a | yes |
| <a name="input_jira_base_url"></a> [jira\_base\_url](#input\_jira\_base\_url) | The base URL for the Jira instance (e.g., https://bcgov.atlassian.net). | `string` | n/a | yes |
| <a name="input_jira_issue_type"></a> [jira\_issue\_type](#input\_jira\_issue\_type) | The Jira issue type for auto-created incidents. | `string` | `"Incident"` | no |
| <a name="input_jira_project_key"></a> [jira\_project\_key](#input\_jira\_project\_key) | The Jira project key for creating incidents (e.g., MCCS). | `string` | n/a | yes |
| <a name="input_jira_user_email"></a> [jira\_user\_email](#input\_jira\_user\_email) | The email address of the Jira API user. | `string` | n/a | yes |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Override for the Key Vault name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_key_vault_sku"></a> [key\_vault\_sku](#input\_key\_vault\_sku) | The SKU for Key Vault. | `string` | `"standard"` | no |
| <a name="input_key_vault_soft_delete_retention_days"></a> [key\_vault\_soft\_delete\_retention\_days](#input\_key\_vault\_soft\_delete\_retention\_days) | The number of days for Key Vault soft delete retention. | `number` | `90` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be deployed. | `string` | `"canadacentral"` | no |
| <a name="input_log_analytics_retention_days"></a> [log\_analytics\_retention\_days](#input\_log\_analytics\_retention\_days) | The number of days to retain logs in Log Analytics. | `number` | `90` | no |
| <a name="input_log_analytics_sku"></a> [log\_analytics\_sku](#input\_log\_analytics\_sku) | The SKU for Log Analytics Workspace. | `string` | `"PerGB2018"` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Override for the Log Analytics Workspace name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_logic_app_name"></a> [logic\_app\_name](#input\_logic\_app\_name) | Override for the Logic App name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_netbox_admin_email"></a> [netbox\_admin\_email](#input\_netbox\_admin\_email) | The email address for the Netbox admin user. | `string` | n/a | yes |
| <a name="input_netbox_cpu"></a> [netbox\_cpu](#input\_netbox\_cpu) | The number of CPU cores for Netbox container. | `number` | `1` | no |
| <a name="input_netbox_image"></a> [netbox\_image](#input\_netbox\_image) | The Docker image for Netbox. | `string` | `"netboxcommunity/netbox:v3.7"` | no |
| <a name="input_netbox_memory"></a> [netbox\_memory](#input\_netbox\_memory) | The memory in GB for Netbox container. | `number` | `2` | no |
| <a name="input_network_manager_ipam_pool_id"></a> [network\_manager\_ipam\_pool\_id](#input\_network\_manager\_ipam\_pool\_id) | The resource ID of the Azure Network Manager IPAM Pool for IP address allocation. Required when use\_ipam is true. | `string` | `null` | no |
| <a name="input_noc_team_group_id"></a> [noc\_team\_group\_id](#input\_noc\_team\_group\_id) | The Object ID of the Entra ID group for the NOC Team (Grafana Editor). | `string` | `null` | no |
| <a name="input_postgresql_admin_username"></a> [postgresql\_admin\_username](#input\_postgresql\_admin\_username) | The administrator username for PostgreSQL. | `string` | `"pgadmin"` | no |
| <a name="input_postgresql_backup_retention_days"></a> [postgresql\_backup\_retention\_days](#input\_postgresql\_backup\_retention\_days) | The number of days to retain PostgreSQL backups. | `number` | `35` | no |
| <a name="input_postgresql_geo_redundant_backup"></a> [postgresql\_geo\_redundant\_backup](#input\_postgresql\_geo\_redundant\_backup) | Whether to enable geo-redundant backups for PostgreSQL. | `bool` | `true` | no |
| <a name="input_postgresql_high_availability"></a> [postgresql\_high\_availability](#input\_postgresql\_high\_availability) | Whether to enable zone-redundant high availability for PostgreSQL. | `bool` | `true` | no |
| <a name="input_postgresql_server_name"></a> [postgresql\_server\_name](#input\_postgresql\_server\_name) | Override for the PostgreSQL Flexible Server name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_postgresql_sku_name"></a> [postgresql\_sku\_name](#input\_postgresql\_sku\_name) | The SKU name for PostgreSQL Flexible Server. | `string` | `"GP_Standard_D2s_v3"` | no |
| <a name="input_postgresql_storage_mb"></a> [postgresql\_storage\_mb](#input\_postgresql\_storage\_mb) | The storage size in MB for PostgreSQL. | `number` | `32768` | no |
| <a name="input_postgresql_version"></a> [postgresql\_version](#input\_postgresql\_version) | The version of PostgreSQL to deploy. | `string` | `"15"` | no |
| <a name="input_prometheus_cpu"></a> [prometheus\_cpu](#input\_prometheus\_cpu) | The number of CPU cores for Prometheus container. | `number` | `1` | no |
| <a name="input_prometheus_image"></a> [prometheus\_image](#input\_prometheus\_image) | The Docker image for Prometheus. | `string` | `"prom/prometheus:v2.48.0"` | no |
| <a name="input_prometheus_memory"></a> [prometheus\_memory](#input\_prometheus\_memory) | The memory in GB for Prometheus container. | `number` | `2` | no |
| <a name="input_prometheus_retention_days"></a> [prometheus\_retention\_days](#input\_prometheus\_retention\_days) | The number of days to retain Prometheus metrics. | `number` | `15` | no |
| <a name="input_redis_image"></a> [redis\_image](#input\_redis\_image) | The Docker image for Redis (Netbox cache). | `string` | `"redis:7-alpine"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Override for the resource group name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_service_desk_group_id"></a> [service\_desk\_group\_id](#input\_service\_desk\_group\_id) | The Object ID of the Entra ID group for Service Desk (Grafana Viewer). | `string` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Override for the Storage Account name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | The subscription ID for the connectivity subscription where resources will be deployed. | `string` | `null` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | The subscription ID for the management subscription. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources. | `map(string)` | `null` | no |
| <a name="input_teams_webhook_url"></a> [teams\_webhook\_url](#input\_teams\_webhook\_url) | The Microsoft Teams incoming webhook URL for alert notifications. | `string` | n/a | yes |
| <a name="input_terraform_spn_object_id"></a> [terraform\_spn\_object\_id](#input\_terraform\_spn\_object\_id) | The Object ID of the Terraform Service Principal for Key Vault access. | `string` | `null` | no |
| <a name="input_use_ipam"></a> [use\_ipam](#input\_use\_ipam) | Whether to use Azure Network Manager IPAM for IP address allocation. If true, network\_manager\_ipam\_pool\_id is required. If false, vnet\_address\_space is required. | `bool` | `true` | no |
| <a name="input_virtual_hub_id"></a> [virtual\_hub\_id](#input\_virtual\_hub\_id) | The resource ID of the Virtual WAN Hub to connect the VNet to. | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space for the VNet (e.g., 10.100.0.0/24). Required when use\_ipam is false. Will be split into /26 subnets. | `string` | `null` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Override for the VNet name. If not provided, a name will be generated. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | The ID of the alert action group. |
| <a name="output_azure_monitor_workspace_id"></a> [azure\_monitor\_workspace\_id](#output\_azure\_monitor\_workspace\_id) | The ID of the Azure Monitor Workspace. |
| <a name="output_azure_monitor_workspace_name"></a> [azure\_monitor\_workspace\_name](#output\_azure\_monitor\_workspace\_name) | The name of the Azure Monitor Workspace. |
| <a name="output_grafana_endpoint"></a> [grafana\_endpoint](#output\_grafana\_endpoint) | The endpoint URL of the Azure Managed Grafana instance. |
| <a name="output_grafana_id"></a> [grafana\_id](#output\_grafana\_id) | The ID of the Azure Managed Grafana instance. |
| <a name="output_grafana_identity_principal_id"></a> [grafana\_identity\_principal\_id](#output\_grafana\_identity\_principal\_id) | The principal ID of the Grafana managed identity. |
| <a name="output_grafana_managed_identity_id"></a> [grafana\_managed\_identity\_id](#output\_grafana\_managed\_identity\_id) | The ID of the Grafana managed identity. |
| <a name="output_grafana_name"></a> [grafana\_name](#output\_grafana\_name) | The name of the Azure Managed Grafana instance. |
| <a name="output_ipam_allocated_cidr"></a> [ipam\_allocated\_cidr](#output\_ipam\_allocated\_cidr) | The CIDR block allocated from IPAM (null if not using IPAM). |
| <a name="output_ipam_allocation_id"></a> [ipam\_allocation\_id](#output\_ipam\_allocation\_id) | The ID of the IPAM allocation (null if not using IPAM). |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace. |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics Workspace. |
| <a name="output_log_analytics_workspace_primary_key"></a> [log\_analytics\_workspace\_primary\_key](#output\_log\_analytics\_workspace\_primary\_key) | The primary shared key of the Log Analytics Workspace. |
| <a name="output_logic_app_callback_url"></a> [logic\_app\_callback\_url](#output\_logic\_app\_callback\_url) | The callback URL for the Logic App HTTP trigger. |
| <a name="output_logic_app_id"></a> [logic\_app\_id](#output\_logic\_app\_id) | The ID of the Logic App. |
| <a name="output_logic_app_managed_identity_id"></a> [logic\_app\_managed\_identity\_id](#output\_logic\_app\_managed\_identity\_id) | The ID of the Logic App managed identity. |
| <a name="output_netbox_private_ip"></a> [netbox\_private\_ip](#output\_netbox\_private\_ip) | The private IP address of the Netbox container instance. Use this for Prometheus scraping and Grafana data source configuration. |
| <a name="output_netbox_storage_account_name"></a> [netbox\_storage\_account\_name](#output\_netbox\_storage\_account\_name) | The name of the Netbox storage account. |
| <a name="output_netbox_url"></a> [netbox\_url](#output\_netbox\_url) | The URL for accessing Netbox (using private IP). |
| <a name="output_postgresql_fqdn"></a> [postgresql\_fqdn](#output\_postgresql\_fqdn) | The FQDN of the PostgreSQL Flexible Server. |
| <a name="output_postgresql_server_id"></a> [postgresql\_server\_id](#output\_postgresql\_server\_id) | The ID of the PostgreSQL Flexible Server. |
| <a name="output_postgresql_server_name"></a> [postgresql\_server\_name](#output\_postgresql\_server\_name) | The name of the PostgreSQL Flexible Server. |
| <a name="output_prometheus_private_ip"></a> [prometheus\_private\_ip](#output\_prometheus\_private\_ip) | The private IP address of the Prometheus container instance. |
| <a name="output_prometheus_storage_account_name"></a> [prometheus\_storage\_account\_name](#output\_prometheus\_storage\_account\_name) | The name of the Prometheus storage account. |
| <a name="output_prometheus_url"></a> [prometheus\_url](#output\_prometheus\_url) | The URL for accessing Prometheus (using private IP). |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the resource group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group. |
| <a name="output_subnet_containers_id"></a> [subnet\_containers\_id](#output\_subnet\_containers\_id) | The ID of the container instances subnet. |
| <a name="output_subnet_postgresql_id"></a> [subnet\_postgresql\_id](#output\_subnet\_postgresql\_id) | The ID of the PostgreSQL subnet. |
| <a name="output_subnet_private_endpoints_id"></a> [subnet\_private\_endpoints\_id](#output\_subnet\_private\_endpoints\_id) | The ID of the private endpoints subnet. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of all created subnets with IDs and CIDRs. |
| <a name="output_virtual_hub_connection_id"></a> [virtual\_hub\_connection\_id](#output\_virtual\_hub\_connection\_id) | The ID of the Virtual Hub Connection. |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the Virtual Network. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the Virtual Network. |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the Virtual Network. |
<!-- END_TF_DOCS -->
