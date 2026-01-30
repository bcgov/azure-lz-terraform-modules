# connectivity

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mccs_observability"></a> [mccs\_observability](#module\_mccs\_observability) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_central_grafana_dns_zone_id"></a> [central\_grafana\_dns\_zone\_id](#input\_central\_grafana\_dns\_zone\_id) | Resource ID of the central Grafana private DNS zone. | `string` | `null` | no |
| <a name="input_central_keyvault_dns_zone_id"></a> [central\_keyvault\_dns\_zone\_id](#input\_central\_keyvault\_dns\_zone\_id) | Resource ID of the central Key Vault private DNS zone. | `string` | `null` | no |
| <a name="input_central_postgresql_dns_zone_id"></a> [central\_postgresql\_dns\_zone\_id](#input\_central\_postgresql\_dns\_zone\_id) | Resource ID of the central PostgreSQL private DNS zone. | `string` | n/a | yes |
| <a name="input_cloud_team_email"></a> [cloud\_team\_email](#input\_cloud\_team\_email) | Cloud team email address. | `string` | n/a | yes |
| <a name="input_cloud_team_group_id"></a> [cloud\_team\_group\_id](#input\_cloud\_team\_group\_id) | Object ID of the Cloud Team Entra ID group. | `string` | n/a | yes |
| <a name="input_enable_alerting"></a> [enable\_alerting](#input\_enable\_alerting) | Whether to enable alerting. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name. | `string` | `"prod"` | no |
| <a name="input_expressroute_circuits"></a> [expressroute\_circuits](#input\_expressroute\_circuits) | Map of ExpressRoute circuits to monitor. | <pre>map(object({<br/>    circuit_name        = string<br/>    resource_group_name = string<br/>    bandwidth_mbps      = number<br/>    location            = string<br/>    provider_name       = optional(string, "Unknown")<br/>  }))</pre> | n/a | yes |
| <a name="input_expressroute_gateways"></a> [expressroute\_gateways](#input\_expressroute\_gateways) | Map of ExpressRoute gateways to monitor. | <pre>map(object({<br/>    gateway_name        = string<br/>    resource_group_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_internet_security_enabled"></a> [internet\_security\_enabled](#input\_internet\_security\_enabled) | Whether to route internet traffic through the hub firewall. | `bool` | `true` | no |
| <a name="input_jira_api_token"></a> [jira\_api\_token](#input\_jira\_api\_token) | Jira API token. | `string` | n/a | yes |
| <a name="input_jira_base_url"></a> [jira\_base\_url](#input\_jira\_base\_url) | Jira base URL. | `string` | n/a | yes |
| <a name="input_jira_project_key"></a> [jira\_project\_key](#input\_jira\_project\_key) | Jira project key. | `string` | n/a | yes |
| <a name="input_jira_user_email"></a> [jira\_user\_email](#input\_jira\_user\_email) | Jira API user email. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region. | `string` | `"canadacentral"` | no |
| <a name="input_netbox_admin_email"></a> [netbox\_admin\_email](#input\_netbox\_admin\_email) | Netbox admin email. | `string` | n/a | yes |
| <a name="input_network_manager_ipam_pool_id"></a> [network\_manager\_ipam\_pool\_id](#input\_network\_manager\_ipam\_pool\_id) | The IPAM Pool ID for IP allocation. Required when use\_ipam is true. | `string` | `null` | no |
| <a name="input_noc_team_group_id"></a> [noc\_team\_group\_id](#input\_noc\_team\_group\_id) | Object ID of the NOC Team Entra ID group. | `string` | `null` | no |
| <a name="input_service_desk_group_id"></a> [service\_desk\_group\_id](#input\_service\_desk\_group\_id) | Object ID of the Service Desk Entra ID group. | `string` | `null` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | The connectivity subscription ID. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | The management subscription ID. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply. | `map(string)` | `{}` | no |
| <a name="input_teams_webhook_url"></a> [teams\_webhook\_url](#input\_teams\_webhook\_url) | Microsoft Teams webhook URL. | `string` | n/a | yes |
| <a name="input_terraform_spn_object_id"></a> [terraform\_spn\_object\_id](#input\_terraform\_spn\_object\_id) | Object ID of the Terraform Service Principal. | `string` | `null` | no |
| <a name="input_use_ipam"></a> [use\_ipam](#input\_use\_ipam) | Whether to use IPAM for IP address allocation. | `bool` | `true` | no |
| <a name="input_virtual_hub_id"></a> [virtual\_hub\_id](#input\_virtual\_hub\_id) | The resource ID of the Virtual WAN Hub to connect the VNet to. | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The VNet address space (e.g., 10.100.0.0/24). Required when use\_ipam is false. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grafana_endpoint"></a> [grafana\_endpoint](#output\_grafana\_endpoint) | The Grafana endpoint URL. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The Key Vault URI. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The Log Analytics Workspace ID. |
| <a name="output_netbox_private_ip"></a> [netbox\_private\_ip](#output\_netbox\_private\_ip) | The private IP of the Netbox container. |
| <a name="output_postgresql_fqdn"></a> [postgresql\_fqdn](#output\_postgresql\_fqdn) | The PostgreSQL server FQDN. |
| <a name="output_prometheus_private_ip"></a> [prometheus\_private\_ip](#output\_prometheus\_private\_ip) | The private IP of the Prometheus container. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of subnet IDs and CIDRs. |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The VNet address space. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The VNet ID. |
<!-- END_TF_DOCS -->
