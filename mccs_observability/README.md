# MCCS Observability Platform

This Terraform module deploys the **Multi-Cloud Connectivity Service (MCCS) Observability Platform** - a unified monitoring solution for BC Government's hybrid cloud connectivity infrastructure.

## Overview

The MCCS Observability Platform provides:

- **Single Pane of Glass**: Consolidated view of all MCCS connections across Azure ExpressRoute (and AWS Direct Connect in Phase 2)
- **Proactive Monitoring**: Real-time alerting on connectivity issues before user impact
- **Rapid Troubleshooting**: Centralized diagnostics to reduce mean time to resolution (MTTR)
- **Network Documentation**: Circuit inventory defined as code in Terraform

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MCCS OBSERVABILITY PLATFORM                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Data Sources              Collection & Storage        Visualization        │
│  ─────────────             ────────────────────        ─────────────        │
│  ExpressRoute    ───►      Log Analytics Workspace ──► Azure Managed        │
│  Circuits                                              Grafana              │
│  Gateways                                                                          │
│                                                                                   │
│  Alerting                          Secrets                                        │
│  ────────                          ───────                                        │
│  Logic App ───► Teams              Key Vault                                      │
│           ───► Jira JSM            (RBAC-enabled)                                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Components

| Component | Description |
|-----------|-------------|
| **Azure Managed Grafana** | Visualization and dashboards with Entra ID authentication |
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
  central_keyvault_dns_zone_id = "/subscriptions/.../privatelink.vaultcore.azure.net"

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

  # Optional: VPN gateways (vWAN hub VPN gateways) for Landing Zone Operations dashboards
  vpn_gateways = {
    "vgw-cc-hub-01" = {
      gateway_name        = "vgw-canadacentral-01"
      resource_group_name = "rg-connectivity"
    }
  }
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

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `location` | Azure region | `string` | `"canadacentral"` |
| `noc_team_group_id` | Entra ID group for NOC Team | `string` | `null` |
| `service_desk_group_id` | Entra ID group for Service Desk | `string` | `null` |
| `enable_alerting` | Enable alerting infrastructure | `bool` | `true` |
| `grafana_sku` | Grafana SKU (Standard/Essential) | `string` | `"Standard"` |
| `tags` | Additional resource tags | `map(string)` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| `resource_group_name` | The name of the resource group |
| `grafana_endpoint` | The Grafana endpoint URL |
| `key_vault_uri` | The Key Vault URI |
| `log_analytics_workspace_id` | The Log Analytics Workspace ID |

## Post-Deployment Steps

### 1. Verify Grafana Data Sources

1. Access Grafana via the private endpoint
2. Verify Azure Monitor data source is connected
3. Dashboards are automatically provisioned (see below)

## Grafana Dashboards

The module provisions the following dashboards when `enable_grafana_dashboards = true` (the flag defaults to `false` so a first apply can create Grafana before a service-account token exists):

**Folder: MCCS Observability** (multi-cloud connectivity)

| Dashboard | UID | Description |
|-----------|-----|-------------|
| **MCCS Overview** | `mccs-overview` | Consolidated view of all ExpressRoute circuits with BGP/ARP availability, bandwidth utilization, and active alerts |
| **ExpressRoute Health** | `expressroute-health` | Detailed health metrics for individual circuits including packet drops, gateway CPU, and troubleshooting guide |

**Folder: Landing Zone Operations** (broader platform views for landing zone administrators)

| Dashboard | UID | Description |
|-----------|-----|-------------|
| **Virtual WAN Hub Health** | `vwan-hub-health` | Hub router capacity (Routing Infrastructure Units), spoke VM utilization, data processed, and hub BGP/route health — targets the vWAN hub in `virtual_hub_id` |
| **VPN Gateway Health** | `vpn-gateway-health` | S2S VPN tunnel bandwidth, ingress/egress packet drops, BGP peers/routes, and tunnel/route diagnostic events (only provisioned when `vpn_gateways` is provided) |
| **Platform Changes (Activity Log)** | `platform-changes` | Subscription control-plane change feed: administrative operations, RBAC changes, failed operations, and service health events from activity logs routed to the workspace (provisioned when `enable_activity_log_diagnostics` is true or `activity_log_workspace_id` points at an existing workspace) |
| **Resource Inventory & Policy** | `resource-inventory-policy` | Resource counts by type/location, recently created resources, and policy compliance summary via Azure Resource Graph |
| **Security Posture (Defender)** | `security-posture` | Defender for Cloud secure score and unhealthy security assessments via Azure Resource Graph (requires Defender for Cloud, free CSPM tier, on the subscription) |
| **Key Vault Access** | `key-vault-access` | Key Vault audit events: secret access, denied attempts (403), distinct callers, hourly operation trends, and recent access feed |

### Dashboard Features

**MCCS Overview:**
- Health summary stats (BGP, ARP, bandwidth, active alerts)
- Time series graphs for all circuits
- Circuit status summary table
- AWS Direct Connect placeholder (Phase 2)

**ExpressRoute Health:**
- Real-time BGP and ARP availability graphs
- Inbound/outbound bandwidth with threshold indicators
- Packet drop monitoring
- Gateway CPU utilization and route counts
- Gateway throughput and routes learned from peer
- Peering route change trend and recent gateway diagnostic events from Log Analytics (GatewayDiagnosticLog / PeeringRouteLog)
- Embedded troubleshooting reference guide

### Dashboard Variables

All dashboards support the following template variables:
- `datasource`: Azure Monitor data source
- `subscription`: Azure subscription selector
- `resource_group`: Resource group filter
- `circuit`: ExpressRoute circuit multi-select
- `gateway`: ExpressRoute gateway selector (ExpressRoute Health only)

### Two-Phase Dashboard Deployment

Dashboard provisioning requires a Grafana service account token for API authentication. The token can only be created after Grafana is deployed, and the Grafana API itself needs an existing token to create service accounts — so the very first token must be created manually in the Grafana UI:

**Phase 1: Deploy infrastructure (without dashboards)**

`enable_grafana_dashboards` defaults to `false`, so a first apply skips dashboard resources and does not look up the Grafana token secret.

```hcl
module "mccs_observability" {
  # ... other config ...
  # enable_grafana_dashboards defaults to false until a token exists
}
```

**Bootstrap: create the first token (manual, once)**
1. Access Grafana UI via the endpoint
2. Navigate to Administration → Users and access → Service accounts
3. Create a service account with "Admin" role, then add a token and copy it
4. Store it as the `grafana-service-account-token` secret in the module's Key Vault
   (or pass it via `grafana_service_account_token` / `TF_VAR_grafana_service_account_token`)

**Phase 2: Re-deploy to provision dashboards**

Set `enable_grafana_dashboards = true` and re-apply. When no token variable is passed,
the module reads the token from the Key Vault automatically, so CI only needs read
access to the vault — no token secret required in CI variables.

```hcl
module "mccs_observability" {
  # ... other config ...
  enable_grafana_dashboards     = true   # Token now found in Key Vault or var
}
```

### Customizing Dashboards

Dashboard JSON files are stored in `dashboards/`:
- `mccs_overview.json.tftpl`
- `expressroute_health.json.tftpl`

To customize dashboards:
1. Export modified dashboard from Grafana UI
2. Update the corresponding JSON file
3. Run `terraform apply` to sync changes

## Alert Definitions

| Alert | Condition | Severity | Notification |
|-------|-----------|----------|--------------|
| BGP Availability Down | < 100% for 5 min | Sev0 (Critical) | Teams + Jira |
| ARP Availability Down | < 100% for 5 min | Sev0 (Critical) | Teams + Jira |
| Bandwidth High | > 80% for 15 min | Sev2 (Warning) | Teams |
| Bandwidth Critical | > 95% for 5 min | Sev1 (Error) | Teams |
| Gateway Unhealthy | BGP peer status < 1 | Sev0 (Critical) | Teams + Jira |

> **Current limitation:** the Logic App alert router forwards the raw alert to the action
> group (email receiver). The Teams and Jira actions are not yet implemented in Terraform,
> so those columns describe the intended routing rather than the deployed behaviour.

## Security

- All resources use private endpoints (no public access)
- Entra ID authentication for Grafana
- Key Vault with RBAC for secrets
- Network Security Groups on subnets
- TLS 1.2+ enforced

## Future Enhancements

### Phase 2: AWS Direct Connect

- AWS Direct Connect monitoring via CloudWatch metrics proxy
- Cross-cloud correlation dashboards
- Unified alerting across Azure and AWS

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.9 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.81 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.9 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.9.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |
| <a name="provider_azurerm.management"></a> [azurerm.management](#provider\_azurerm.management) | 4.81.0 |
| <a name="provider_grafana"></a> [grafana](#provider\_grafana) | 3.25.9 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_dashboard_grafana.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dashboard_grafana) | resource |
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.grafana_service_account_token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.jira_api_token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.jumpbox_admin_password](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.teams_webhook_url](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_logic_app_action_custom.parse_alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_action_custom) | resource |
| [azurerm_logic_app_trigger_http_request.alert_trigger](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_trigger_http_request) | resource |
| [azurerm_logic_app_workflow.alert_router](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/logic_app_workflow) | resource |
| [azurerm_monitor_action_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_activity_log_alert.resource_health](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert) | resource |
| [azurerm_monitor_diagnostic_setting.activity_log](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.expressroute_circuits](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.expressroute_gateways](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.grafana](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.log_analytics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.logic_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.vpn_gateways](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_metric_alert.arp_availability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.bandwidth_critical](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.bandwidth_warning](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.bgp_availability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.gateway_health](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_workspace) | resource |
| [azurerm_network_interface.jumpbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.jumpbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_manager_ipam_pool_static_cidr.mccs_observability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_manager_ipam_pool_static_cidr) | resource |
| [azurerm_network_security_group.jumpbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_private_endpoint.grafana](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.cloud_team_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cloud_team_grafana_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cloud_team_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cloud_team_vm_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_activity_log_workspace_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_expressroute_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_firewall_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_gateway_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_log_analytics_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_monitoring_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_virtual_hub_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.grafana_vpn_gateway_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.logic_app_secrets_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.noc_team_grafana_editor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.service_desk_grafana_viewer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.terraform_spn_secrets_officer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_hub_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection) | resource |
| [azurerm_virtual_machine_extension.aad_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_windows_virtual_machine.jumpbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [grafana_dashboard.azure_firewall_health](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.expressroute_health](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.key_vault_access](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.landing_zone_home](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.mccs_overview](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.platform_changes](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.resource_inventory_policy](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.security_posture](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.vpn_gateway_health](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_dashboard.vwan_hub_health](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/dashboard) | resource |
| [grafana_data_source.azure_monitor](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/data_source) | resource |
| [grafana_data_source.cloudwatch](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/data_source) | resource |
| [grafana_data_source.log_analytics](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/data_source) | resource |
| [grafana_folder.lz_operations](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.mccs](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.mccs_overview](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.root](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_folder.security](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/folder) | resource |
| [grafana_service_account.terraform](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/service_account) | resource |
| [grafana_service_account_token.terraform](https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/service_account_token) | resource |
| [random_password.jumpbox_admin](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azuread_group.cloud_team](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_express_route_circuit.circuits](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/express_route_circuit) | data source |
| [azurerm_firewall.azure_firewalls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/firewall) | data source |
| [azurerm_key_vault_secret.aws_access_key_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.aws_secret_access_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_key_vault_secret.grafana_token](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_management_group.grafana_scope](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/management_group) | data source |
| [azurerm_virtual_network_gateway.gateways](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network_gateway) | data source |
| [azurerm_vpn_gateway.vpn_gateways](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/vpn_gateway) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | Override for the Action Group name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_activity_log_workspace_id"></a> [activity\_log\_workspace\_id](#input\_activity\_log\_workspace\_id) | Log Analytics workspace resource ID used by the Platform Changes dashboard. Defaults to this module's workspace. Point this at the CAF/platform workspace when activity logs are already shipped there. | `string` | `null` | no |
| <a name="input_alert_evaluation_frequency"></a> [alert\_evaluation\_frequency](#input\_alert\_evaluation\_frequency) | How often alert rules are evaluated. | `string` | `"PT5M"` | no |
| <a name="input_alert_window_size"></a> [alert\_window\_size](#input\_alert\_window\_size) | The time window for alert evaluation. | `string` | `"PT5M"` | no |
| <a name="input_allowed_ip_addresses"></a> [allowed\_ip\_addresses](#input\_allowed\_ip\_addresses) | List of IP addresses or CIDR ranges allowed to reach the Key Vault public endpoint and the jump box NSG. Used for Terraform runners or admin access. | `list(string)` | `[]` | no |
| <a name="input_arp_availability_threshold"></a> [arp\_availability\_threshold](#input\_arp\_availability\_threshold) | ARP availability percentage threshold for critical alerts. | `number` | `100` | no |
| <a name="input_aws_access_key_secret_name"></a> [aws\_access\_key\_secret\_name](#input\_aws\_access\_key\_secret\_name) | Key Vault secret name for the AWS access key ID used by CloudWatch. | `string` | `"grafana-aws-access-key-id"` | no |
| <a name="input_aws_cloudwatch_default_region"></a> [aws\_cloudwatch\_default\_region](#input\_aws\_cloudwatch\_default\_region) | Default AWS region for the CloudWatch data source (Direct Connect metrics live here). | `string` | `"ca-central-1"` | no |
| <a name="input_aws_secret_key_secret_name"></a> [aws\_secret\_key\_secret\_name](#input\_aws\_secret\_key\_secret\_name) | Key Vault secret name for the AWS secret access key used by CloudWatch. | `string` | `"grafana-aws-secret-access-key"` | no |
| <a name="input_azure_firewalls"></a> [azure\_firewalls](#input\_azure\_firewalls) | Map of Azure Firewalls to monitor (typically the vWAN hub firewall). | <pre>map(object({<br/>    firewall_name       = string<br/>    resource_group_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_bandwidth_critical_threshold"></a> [bandwidth\_critical\_threshold](#input\_bandwidth\_critical\_threshold) | Bandwidth utilization percentage threshold for critical alerts. | `number` | `95` | no |
| <a name="input_bandwidth_warning_threshold"></a> [bandwidth\_warning\_threshold](#input\_bandwidth\_warning\_threshold) | Bandwidth utilization percentage threshold for warning alerts. | `number` | `80` | no |
| <a name="input_bgp_availability_threshold"></a> [bgp\_availability\_threshold](#input\_bgp\_availability\_threshold) | BGP availability percentage threshold for critical alerts. | `number` | `100` | no |
| <a name="input_central_grafana_dns_zone_id"></a> [central\_grafana\_dns\_zone\_id](#input\_central\_grafana\_dns\_zone\_id) | The resource ID of the central Private DNS Zone for Grafana (privatelink.grafana.azure.com). | `string` | `null` | no |
| <a name="input_central_keyvault_dns_zone_id"></a> [central\_keyvault\_dns\_zone\_id](#input\_central\_keyvault\_dns\_zone\_id) | The resource ID of the central Private DNS Zone for Key Vault (privatelink.vaultcore.azure.net). | `string` | `null` | no |
| <a name="input_cloud_team_email"></a> [cloud\_team\_email](#input\_cloud\_team\_email) | The email address for the Cloud Team (fallback for alerts). | `string` | n/a | yes |
| <a name="input_cloud_team_group_name"></a> [cloud\_team\_group\_name](#input\_cloud\_team\_group\_name) | The display name of the Entra ID group for the Cloud Team (e.g., 'PIM\_DO\_PuC\_Ops\_Infra\_O'). Used to look up the group and grant Grafana Admin, Key Vault Secrets Officer, and Contributor access. | `string` | n/a | yes |
| <a name="input_create_grafana_service_account"></a> [create\_grafana\_service\_account](#input\_create\_grafana\_service\_account) | Whether to also create a Grafana service account through the Grafana API. The API needs an existing token, so the first bootstrap must be done manually in the Grafana UI; keep false once the token is provided. | `bool` | `false` | no |
| <a name="input_create_private_dns_zone_groups"></a> [create\_private\_dns\_zone\_groups](#input\_create\_private\_dns\_zone\_groups) | Whether to create private DNS zone groups for private endpoints. Set to false if using DINE policies. | `bool` | `false` | no |
| <a name="input_deploy_jumpbox"></a> [deploy\_jumpbox](#input\_deploy\_jumpbox) | Whether to deploy a Windows jump box for accessing private resources. | `bool` | `false` | no |
| <a name="input_diagnostics_retention_days"></a> [diagnostics\_retention\_days](#input\_diagnostics\_retention\_days) | Number of days to retain diagnostic logs. Set to 0 for unlimited retention. | `number` | `90` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS server IP addresses for the VNet. Typically the Azure Firewall private IP for centralized DNS resolution. | `list(string)` | `[]` | no |
| <a name="input_enable_activity_log_diagnostics"></a> [enable\_activity\_log\_diagnostics](#input\_enable\_activity\_log\_diagnostics) | Whether to route subscription activity logs (administrative changes, service/resource health, policy) to the Log Analytics workspace. | `bool` | `true` | no |
| <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting) | Whether to enable alerting infrastructure (Action Groups, Alert Rules, Logic App). | `bool` | `true` | no |
| <a name="input_enable_aws_cloudwatch"></a> [enable\_aws\_cloudwatch](#input\_enable\_aws\_cloudwatch) | Provision a CloudWatch data source from Key Vault AWS keys and enable Direct Connect and AWS VPN panels on MCCS Overview. | `bool` | `false` | no |
| <a name="input_enable_expressroute_diagnostics"></a> [enable\_expressroute\_diagnostics](#input\_enable\_expressroute\_diagnostics) | Whether to enable diagnostic settings on ExpressRoute circuits and gateways. | `bool` | `true` | no |
| <a name="input_enable_grafana_dashboards"></a> [enable\_grafana\_dashboards](#input\_enable\_grafana\_dashboards) | Whether to provision Grafana dashboards via Terraform. Keep false on first apply: the Grafana API token does not exist until after Grafana is deployed and the token is stored in Key Vault or passed via grafana\_service\_account\_token. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name (e.g., prod, dev, staging). | `string` | n/a | yes |
| <a name="input_expressroute_circuits"></a> [expressroute\_circuits](#input\_expressroute\_circuits) | Map of ExpressRoute circuits to monitor. | <pre>map(object({<br/>    circuit_name        = string<br/>    resource_group_name = string<br/>    bandwidth_mbps      = number<br/>    location            = string<br/>    provider_name       = optional(string, "Unknown")<br/>  }))</pre> | n/a | yes |
| <a name="input_expressroute_gateways"></a> [expressroute\_gateways](#input\_expressroute\_gateways) | Map of classic Virtual Network ExpressRoute gateways (Microsoft.Network/virtualNetworkGateways) to monitor. | <pre>map(object({<br/>    gateway_name        = string<br/>    resource_group_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_grafana_api_key_enabled"></a> [grafana\_api\_key\_enabled](#input\_grafana\_api\_key\_enabled) | Whether to enable API key authentication for Grafana. | `bool` | `true` | no |
| <a name="input_grafana_deterministic_outbound_ip"></a> [grafana\_deterministic\_outbound\_ip](#input\_grafana\_deterministic\_outbound\_ip) | Whether to enable deterministic outbound IP for Grafana. | `bool` | `true` | no |
| <a name="input_grafana_monitoring_management_group_id"></a> [grafana\_monitoring\_management\_group\_id](#input\_grafana\_monitoring\_management\_group\_id) | Management group ID that the Grafana managed identity can read (Monitoring Reader and Reader). When set, dashboards can query every subscription under that group. When null, access is limited to the connectivity subscription. | `string` | `null` | no |
| <a name="input_grafana_name"></a> [grafana\_name](#input\_grafana\_name) | Override for the Azure Managed Grafana name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_grafana_public_network_access"></a> [grafana\_public\_network\_access](#input\_grafana\_public\_network\_access) | Whether to enable public network access to Grafana. | `bool` | `false` | no |
| <a name="input_grafana_service_account_token"></a> [grafana\_service\_account\_token](#input\_grafana\_service\_account\_token) | Grafana service account token for dashboard provisioning. Optional: when omitted and enable\_grafana\_dashboards is true, the module reads the grafana-service-account-token secret from the module's Key Vault instead. | `string` | `""` | no |
| <a name="input_grafana_sku"></a> [grafana\_sku](#input\_grafana\_sku) | The SKU for Azure Managed Grafana. | `string` | `"Standard"` | no |
| <a name="input_grafana_zone_redundancy"></a> [grafana\_zone\_redundancy](#input\_grafana\_zone\_redundancy) | Whether to enable zone redundancy for Grafana. | `bool` | `true` | no |
| <a name="input_internet_security_enabled"></a> [internet\_security\_enabled](#input\_internet\_security\_enabled) | Whether to enable internet security (route internet traffic through the hub firewall). | `bool` | `true` | no |
| <a name="input_jira_api_token"></a> [jira\_api\_token](#input\_jira\_api\_token) | The Jira API token for authentication. | `string` | n/a | yes |
| <a name="input_jira_base_url"></a> [jira\_base\_url](#input\_jira\_base\_url) | The base URL for the Jira instance (e.g., https://bcgov.atlassian.net). | `string` | n/a | yes |
| <a name="input_jira_issue_type"></a> [jira\_issue\_type](#input\_jira\_issue\_type) | The Jira issue type for auto-created incidents. | `string` | `"Incident"` | no |
| <a name="input_jira_project_key"></a> [jira\_project\_key](#input\_jira\_project\_key) | The Jira project key for creating incidents (e.g., MCCS). | `string` | n/a | yes |
| <a name="input_jira_user_email"></a> [jira\_user\_email](#input\_jira\_user\_email) | The email address of the Jira API user. | `string` | n/a | yes |
| <a name="input_jumpbox_admin_username"></a> [jumpbox\_admin\_username](#input\_jumpbox\_admin\_username) | The administrator username for the jump box. | `string` | `"azureadmin"` | no |
| <a name="input_jumpbox_enable_aad_login"></a> [jumpbox\_enable\_aad\_login](#input\_jumpbox\_enable\_aad\_login) | Whether to enable Entra ID (AAD) login for the jump box. | `bool` | `true` | no |
| <a name="input_jumpbox_vm_size"></a> [jumpbox\_vm\_size](#input\_jumpbox\_vm\_size) | The VM size for the jump box. | `string` | `"Standard_B2s"` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | Override for the Key Vault name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_key_vault_sku"></a> [key\_vault\_sku](#input\_key\_vault\_sku) | The SKU for Key Vault. | `string` | `"standard"` | no |
| <a name="input_key_vault_soft_delete_retention_days"></a> [key\_vault\_soft\_delete\_retention\_days](#input\_key\_vault\_soft\_delete\_retention\_days) | The number of days for Key Vault soft delete retention. | `number` | `90` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be deployed. | `string` | `"canadacentral"` | no |
| <a name="input_log_analytics_retention_days"></a> [log\_analytics\_retention\_days](#input\_log\_analytics\_retention\_days) | The number of days to retain logs in Log Analytics. | `number` | `90` | no |
| <a name="input_log_analytics_sku"></a> [log\_analytics\_sku](#input\_log\_analytics\_sku) | The SKU for Log Analytics Workspace. | `string` | `"PerGB2018"` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Override for the Log Analytics Workspace name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_logic_app_name"></a> [logic\_app\_name](#input\_logic\_app\_name) | Override for the Logic App name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_network_manager_ipam_pool_id"></a> [network\_manager\_ipam\_pool\_id](#input\_network\_manager\_ipam\_pool\_id) | The resource ID of the Azure Network Manager IPAM Pool for IP address allocation. Required when use\_ipam is true. | `string` | `null` | no |
| <a name="input_noc_team_group_id"></a> [noc\_team\_group\_id](#input\_noc\_team\_group\_id) | The Object ID of the Entra ID group for the NOC Team (Grafana Editor). | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Override for the resource group name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_service_desk_group_id"></a> [service\_desk\_group\_id](#input\_service\_desk\_group\_id) | The Object ID of the Entra ID group for Service Desk (Grafana Viewer). | `string` | `null` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | The subscription ID for the connectivity subscription where resources will be deployed. | `string` | `null` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | The subscription ID for the management subscription. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_teams_webhook_url"></a> [teams\_webhook\_url](#input\_teams\_webhook\_url) | The Microsoft Teams incoming webhook URL for alert notifications. | `string` | n/a | yes |
| <a name="input_terraform_spn_object_id"></a> [terraform\_spn\_object\_id](#input\_terraform\_spn\_object\_id) | The Object ID of the Terraform Service Principal for Key Vault access. | `string` | `null` | no |
| <a name="input_use_ipam"></a> [use\_ipam](#input\_use\_ipam) | Whether to use Azure Network Manager IPAM for IP address allocation. If true, network\_manager\_ipam\_pool\_id is required. If false, vnet\_address\_space is required. | `bool` | `true` | no |
| <a name="input_virtual_hub_express_route_gateways"></a> [virtual\_hub\_express\_route\_gateways](#input\_virtual\_hub\_express\_route\_gateways) | Map of vWAN hub ExpressRoute gateways (Microsoft.Network/expressRouteGateways) to monitor. This landing zone uses these, not classic virtual network gateways. | <pre>map(object({<br/>    gateway_name        = string<br/>    resource_group_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_virtual_hub_id"></a> [virtual\_hub\_id](#input\_virtual\_hub\_id) | The resource ID of the Virtual WAN Hub to connect the VNet to. | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space for the VNet (e.g., 10.100.0.0/24). Required when use\_ipam is false. Will be split into /26 subnets. | `string` | `null` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Override for the VNet name. If not provided, a name will be generated. | `string` | `null` | no |
| <a name="input_vpn_gateways"></a> [vpn\_gateways](#input\_vpn\_gateways) | Map of VPN gateways to monitor (Microsoft.Network/vpnGateways, e.g. vWAN hub VPN gateways). | <pre>map(object({<br/>    gateway_name        = string<br/>    resource_group_name = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | The ID of the alert action group. |
| <a name="output_azure_monitor_workspace_id"></a> [azure\_monitor\_workspace\_id](#output\_azure\_monitor\_workspace\_id) | The ID of the Azure Monitor Workspace. |
| <a name="output_azure_monitor_workspace_name"></a> [azure\_monitor\_workspace\_name](#output\_azure\_monitor\_workspace\_name) | The name of the Azure Monitor Workspace. |
| <a name="output_grafana_dashboard_expressroute_health_url"></a> [grafana\_dashboard\_expressroute\_health\_url](#output\_grafana\_dashboard\_expressroute\_health\_url) | The URL for the ExpressRoute Health dashboard. |
| <a name="output_grafana_dashboard_folder_uid"></a> [grafana\_dashboard\_folder\_uid](#output\_grafana\_dashboard\_folder\_uid) | The UID of the Connectivity Grafana dashboard folder (null if dashboards not provisioned). |
| <a name="output_grafana_dashboard_mccs_overview_url"></a> [grafana\_dashboard\_mccs\_overview\_url](#output\_grafana\_dashboard\_mccs\_overview\_url) | The URL for the MCCS Overview dashboard. |
| <a name="output_grafana_dashboards"></a> [grafana\_dashboards](#output\_grafana\_dashboards) | Map of all provisioned Grafana dashboard URLs (null if dashboards not provisioned). |
| <a name="output_grafana_endpoint"></a> [grafana\_endpoint](#output\_grafana\_endpoint) | The endpoint URL of the Azure Managed Grafana instance. |
| <a name="output_grafana_id"></a> [grafana\_id](#output\_grafana\_id) | The ID of the Azure Managed Grafana instance. |
| <a name="output_grafana_identity_principal_id"></a> [grafana\_identity\_principal\_id](#output\_grafana\_identity\_principal\_id) | The principal ID of the Grafana managed identity. |
| <a name="output_grafana_managed_identity_id"></a> [grafana\_managed\_identity\_id](#output\_grafana\_managed\_identity\_id) | The ID of the Grafana managed identity. |
| <a name="output_grafana_name"></a> [grafana\_name](#output\_grafana\_name) | The name of the Azure Managed Grafana instance. |
| <a name="output_grafana_root_folder_uid"></a> [grafana\_root\_folder\_uid](#output\_grafana\_root\_folder\_uid) | The UID of the top-level Landing Zone Grafana folder (null if dashboards not provisioned). |
| <a name="output_ipam_allocated_cidr"></a> [ipam\_allocated\_cidr](#output\_ipam\_allocated\_cidr) | The CIDR block allocated from IPAM (null if not using IPAM). |
| <a name="output_ipam_allocation_id"></a> [ipam\_allocation\_id](#output\_ipam\_allocation\_id) | The ID of the IPAM allocation (null if not using IPAM). |
| <a name="output_jumpbox_admin_username"></a> [jumpbox\_admin\_username](#output\_jumpbox\_admin\_username) | The admin username for the jump box. |
| <a name="output_jumpbox_name"></a> [jumpbox\_name](#output\_jumpbox\_name) | The name of the Windows jump box VM. |
| <a name="output_jumpbox_private_ip"></a> [jumpbox\_private\_ip](#output\_jumpbox\_private\_ip) | The private IP address of the Windows jump box. |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The name of the Key Vault. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics Workspace. |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics Workspace. |
| <a name="output_log_analytics_workspace_primary_key"></a> [log\_analytics\_workspace\_primary\_key](#output\_log\_analytics\_workspace\_primary\_key) | The primary shared key of the Log Analytics Workspace. |
| <a name="output_logic_app_callback_url"></a> [logic\_app\_callback\_url](#output\_logic\_app\_callback\_url) | The callback URL for the Logic App HTTP trigger. |
| <a name="output_logic_app_id"></a> [logic\_app\_id](#output\_logic\_app\_id) | The ID of the Logic App. |
| <a name="output_logic_app_managed_identity_id"></a> [logic\_app\_managed\_identity\_id](#output\_logic\_app\_managed\_identity\_id) | The ID of the Logic App managed identity. |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the resource group. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group. |
| <a name="output_subnet_private_endpoints_id"></a> [subnet\_private\_endpoints\_id](#output\_subnet\_private\_endpoints\_id) | The ID of the private endpoints subnet. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of all created subnets with IDs and CIDRs. |
| <a name="output_virtual_hub_connection_id"></a> [virtual\_hub\_connection\_id](#output\_virtual\_hub\_connection\_id) | The ID of the Virtual Hub Connection. |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the Virtual Network. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the Virtual Network. |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the Virtual Network. |
<!-- END_TF_DOCS -->
