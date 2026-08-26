# ALZ AVM Platform Lessons Learned

We need `Owner` permissons on the subscriptions that will be moved into the new Management Group hierarchy.

Error: `"Permission to write and delete on resources of type 'Microsoft.Authorization/roleAssignments' is required on the subscription or its ancestors."`


The `module.platform_subscriptions.module.lz_vending["identity"].module.subscription[0].terraform_data.replacement[0]` triggers a replacement in Terraform plan





This module creates a greenfield Azure Landing Zone platform baseline using Azure Verified Modules (AVM), with a dedicated Security subscription and Security management group.

## Design goals

- AVM-first composition for management groups/policy, management resources, and Virtual WAN connectivity.
- Greenfield platform topology with dedicated platform subscriptions: management, connectivity, identity, security.
- Component reference parity from existing CAF implementation for selected capabilities:
  - Virtual WAN
  - Azure Firewall in Virtual WAN hubs
  - Private DNS zones and links
- Built-in ALZ policy baseline first, with extension points for later customizations.

## Implemented in v1

- AVM ALZ core module composition with custom architecture including Security management group.
- AVM ALZ management resources in dedicated management subscription.
- AVM ALZ connectivity Virtual WAN composition in dedicated connectivity subscription.
- ExpressRoute and S2S VPN (IPSec) support for Virtual WAN hubs through first-class module inputs.
- Centralized logging default for hub firewall policy insights to the Management subscription Log Analytics workspace.
- Optional AMBA resource deployment in management subscription, scoped to the `platform` management group branch (not workload landing zones).
- Optional identity/security bootstrap resource groups to anchor dedicated platform subscriptions.
- Configurable management group IDs via `management_group_names` for subscription placement and AMBA platform-branch targeting.
- Custom architecture profile excludes `corp`, `online`, and `sandbox` management groups.

## Stubs and placeholders

- Fine-grained policy overrides are accepted through pass-through variables.
- AMBA policy defaults are seeded with safe placeholders where organization-specific values are unknown.
- Deeper security workload bootstrap in security subscription is intentionally left for phase 2.

## Management Group Naming

- Use `management_group_names` to set IDs used by placement logic (`root`, `platform`, `management`, `connectivity`, `identity`, `security`, `landingzones`).
- If you change any IDs from defaults, create or update a matching architecture file under `./lib` and set `architecture_name` to that file's architecture name.
- The shipped `alz_custom` architecture includes `landingzones` but intentionally excludes `corp`, `online`, and `sandbox`.

## Usage

See examples under examples/greenfield-vwan.

## Connectivity Extensions

- Set `enable_express_route = true` to enable ExpressRoute gateway resources on configured hubs.
- Set `enable_s2s_vpn = true` to enable S2S VPN gateway resources on configured hubs.
- Set `external_base_firewall_policy_id` to enforce inheritance from an externally managed base firewall policy across hub firewall policies.
- Provide `express_route_circuit_connections_by_hub` to attach ER circuits to specific hubs.
- Provide `vpn_sites_by_hub` and `vpn_site_connections_by_hub` for IPSec S2S site definitions and connections.
- Provide `routing_intents_by_hub` to layer routing intents per hub without inlining them in `virtual_hubs`.
- Provide `private_dns_zones_by_hub` and `private_dns_resolver_by_hub` to apply hub-specific private DNS zone and resolver overrides during migration.

## Centralized Logging

- `enable_centralized_logging` defaults to `true`.
- When enabled, each hub's `firewall_policy.insights.default_log_analytics_workspace_id` defaults to the Log Analytics workspace created in the Management subscription.
- You can still override hub-level `firewall_policy` values in `virtual_hubs`.

## Custom Policy Support (AVM + ALZ)

Yes. The AVM ALZ stack supports policy customization and assignment workflows.

- `avm-ptn-alz` supports policy value and assignment customization through module inputs such as `policy_default_values` and `policy_assignments_to_modify`.
- The `alz` provider supports custom ALZ library content through `library_references`, and this module already loads `./lib` for custom architecture/policy assets.
- Additional custom policy library references can be passed through `custom_alz_library_references`.

Recommendation for AVM-CAF:

- Include an optional policy-extension sub-module/pattern as part of this AVM-CAF stack for organization guardrails that are platform baseline concerns.
- Keep policy content versioned in-repo (for example under `./lib`) and drive rollout with explicit version references.
- Treat workload/team-specific policy exceptions and rapid-change policy experiments as separate overlays, not baseline.
- See `examples/greenfield-vwan/terraform.tfvars.example` for `policy_default_values` examples and `examples/greenfield-vwan/locals.tf` for `policy_assignments_to_modify` examples.

Future-proofing guidance:

- Prefer a stable baseline policy profile in AVM-CAF, then layer environment-specific overrides through `policy_default_values` and `policy_assignments_to_modify`.
- Keep custom policy definitions and initiatives decoupled from workload repos to avoid drift and circular dependencies.

## Private DNS Spoke/Resolver Support

Yes. AVM connectivity virtual-wan supports private DNS zone and private DNS resolver constructs, and this module already exposes migration-friendly inputs:

- `private_dns_zones_by_hub`
- `private_dns_resolver_by_hub`
- `private_dns_enable_internet_fallback` (defaults to `true`, wiring `NxDomainRedirect`)
- `private_dns_resolver_virtual_network_resource_id_by_hub` (default resolver VNet link map)

Default behavior in this module:

- Private DNS zone links default to internet fallback (`NxDomainRedirect`) when `private_dns_enable_internet_fallback = true`.
- When `private_dns_resolver_virtual_network_resource_id_by_hub` is supplied, private DNS zones include a default virtual network link to the resolver VNet for that hub.

Recommendation for AVM-CAF:

- Include private DNS resolver/zone support in the AVM-CAF platform module as an optional baseline capability.
- Keep it enabled by profile when the platform owns shared DNS and hub-spoke name resolution.
- Keep a separate DNS stack only when there is a hard operational boundary (for example, independent DNS lifecycle, dedicated DNS platform team, or non-standard resolver topology not suitable for the shared hub baseline).

## Keep Separate From AVM-CAF (and Why)

The following should generally remain separate stacks from the AVM-CAF baseline:

- ExpressRoute circuit/peering/provider-side onboarding.
Reason: Carrier coordination, long lead times, and external approval workflows differ from platform baseline cadence.

- Site-to-site VPN partner onboarding and connection changes.
Reason: Frequent partner-specific updates and operational ownership are usually network-operations concerns.

- High-churn firewall rule catalogs and team-owned IP groups.
Reason: Application/team policy changes occur much faster than platform baseline releases and should be delegated.

- Post-deploy vWAN routing intent experiments or one-off azapi updates.
Reason: These are often iterative operational changes and can require controlled rollout/rollback outside baseline provisioning.

- Workload- or product-specific private DNS exceptions.
Reason: Service onboarding exceptions can be frequent and should not destabilize shared platform DNS baseline.

- Optional operations add-ons with separate ownership (for example specialized monitoring packs beyond baseline).
Reason: Different lifecycle, approval path, and blast radius than core platform provisioning.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12, < 2.0 |
| <a name="requirement_alz"></a> [alz](#requirement\_alz) | ~> 0.21 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.12.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_management_groups"></a> [management\_groups](#module\_management\_groups) | ./modules/management_groups | n/a |
| <a name="module_platform_subscriptions"></a> [platform\_subscriptions](#module\_platform\_subscriptions) | ./modules/platform_subscriptions | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_client_config.current](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architecture_name"></a> [architecture\_name](#input\_architecture\_name) | ALZ architecture definition name in ./lib. | `string` | `"var_alz_custom"` | no |
| <a name="input_automation_account_encryption"></a> [automation\_account\_encryption](#input\_automation\_account\_encryption) | The encryption configuration for the Azure Automation Account. | <pre>object({<br/>    key_vault_key_id          = string<br/>    user_assigned_identity_id = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_automation_account_identity"></a> [automation\_account\_identity](#input\_automation\_account\_identity) | The identity to assign to the Azure Automation Account. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(set(string), null)<br/>  })</pre> | `null` | no |
| <a name="input_automation_account_local_authentication_enabled"></a> [automation\_account\_local\_authentication\_enabled](#input\_automation\_account\_local\_authentication\_enabled) | Whether or not local authentication is enabled for the Azure Automation Account. | `bool` | `true` | no |
| <a name="input_automation_account_location"></a> [automation\_account\_location](#input\_automation\_account\_location) | The Azure region of the Azure Automation Account to deploy. This supports overriding the location variable in specific cases. | `string` | `null` | no |
| <a name="input_automation_account_name"></a> [automation\_account\_name](#input\_automation\_account\_name) | The name of the Azure Automation Account to create. | `string` | n/a | yes |
| <a name="input_automation_account_public_network_access_enabled"></a> [automation\_account\_public\_network\_access\_enabled](#input\_automation\_account\_public\_network\_access\_enabled) | Whether or not public network access is enabled for the Azure Automation Account. | `bool` | `true` | no |
| <a name="input_automation_account_sku_name"></a> [automation\_account\_sku\_name](#input\_automation\_account\_sku\_name) | The name of the SKU for the Azure Automation Account to create. | `string` | `"Basic"` | no |
| <a name="input_data_collection_rules"></a> [data\_collection\_rules](#input\_data\_collection\_rules) | Enables customisation of the data collection rules for Azure Monitor.<br/>This is an object with attributes pertaining to the three DCRs that are created by this module.<br/><br/>Each object has the following attributes:<br/><br/>- enabled (Optional) - Whether or not to create the data collection rule. Defaults to `true`.<br/>- name (Required) - The name of the data collection rule. For the default values, see the default variable value.<br/>- location (Optional) - The Azure region of the data collection rule. Defaults to the value of the location variable.<br/>- tags (Optional) - A map of tags to apply to the data collection rule. Defaults to `null`.<br/><br/>The defender\_sql object has an additional attribute:<br/><br/>- enable\_collection\_of\_sql\_queries\_for\_security\_research (Optional) - Whether or not to enable collection of SQL queries for security research. Defaults to `false`. | <pre>object({<br/>    change_tracking = object({<br/>      enabled  = optional(bool, true)<br/>      name     = string<br/>      location = optional(string, null)<br/>      tags     = optional(map(string), null)<br/>    })<br/>    vm_insights = object({<br/>      enabled  = optional(bool, true)<br/>      name     = string<br/>      location = optional(string, null)<br/>      tags     = optional(map(string), null)<br/>    })<br/>    defender_sql = object({<br/>      enabled                                                = optional(bool, true)<br/>      name                                                   = string<br/>      location                                               = optional(string, null)<br/>      tags                                                   = optional(map(string), null)<br/>      enable_collection_of_sql_queries_for_security_research = optional(bool, false)<br/>    })<br/>  })</pre> | <pre>{<br/>  "change_tracking": {<br/>    "name": "dcr-change-tracking"<br/>  },<br/>  "defender_sql": {<br/>    "name": "dcr-defender-sql"<br/>  },<br/>  "vm_insights": {<br/>    "name": "dcr-vm-insights"<br/>  }<br/>}</pre> | no |
| <a name="input_linked_automation_account_creation_enabled"></a> [linked\_automation\_account\_creation\_enabled](#input\_linked\_automation\_account\_creation\_enabled) | A boolean flag to determine whether to deploy the Azure Automation Account linked to the Log Analytics Workspace or not. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The default location for resources in this management group. Used for policy managed identities. | `string` | n/a | yes |
| <a name="input_log_analytics_solution_plans"></a> [log\_analytics\_solution\_plans](#input\_log\_analytics\_solution\_plans) | The Log Analytics Solution Plans to create.<br/>Do not add the SecurityInsights solution plan here, this deployment method is deprecated. Instead refer to `sentinel_onboarding` variable.<br/><br/>The value of this variable is a list of objects with the following attributes:<br/><br/>- product (Required) - The product name of the solution plan, e.g. `OMSGallery/ContainerInsights`.<br/>- publisher (Optional) - The publisher name of the solution plan, e.g. `Microsoft`. Defaults to `Microsoft`. | <pre>list(object({<br/>    product   = string<br/>    publisher = optional(string, "Microsoft")<br/>  }))</pre> | <pre>[<br/>  {<br/>    "product": "OMSGallery/ContainerInsights",<br/>    "publisher": "Microsoft"<br/>  },<br/>  {<br/>    "product": "OMSGallery/VMInsights",<br/>    "publisher": "Microsoft"<br/>  }<br/>]</pre> | no |
| <a name="input_log_analytics_workspace_allow_resource_only_permissions"></a> [log\_analytics\_workspace\_allow\_resource\_only\_permissions](#input\_log\_analytics\_workspace\_allow\_resource\_only\_permissions) | Whether or not to allow resource-only permissions for the Log Analytics Workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_cmk_for_query_forced"></a> [log\_analytics\_workspace\_cmk\_for\_query\_forced](#input\_log\_analytics\_workspace\_cmk\_for\_query\_forced) | Whether or not to force the use of customer-managed keys for query in the Log Analytics Workspace. | `bool` | `null` | no |
| <a name="input_log_analytics_workspace_creation_enabled"></a> [log\_analytics\_workspace\_creation\_enabled](#input\_log\_analytics\_workspace\_creation\_enabled) | Whether or not to create a Log Analytics Workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_daily_quota_gb"></a> [log\_analytics\_workspace\_daily\_quota\_gb](#input\_log\_analytics\_workspace\_daily\_quota\_gb) | The daily ingestion quota in GB for the Log Analytics Workspace. | `number` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the pre-existing Log Analytics Workspace to use. Required if `log_analytics_workspace_creation_enabled` is `false`. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_internet_ingestion_enabled"></a> [log\_analytics\_workspace\_internet\_ingestion\_enabled](#input\_log\_analytics\_workspace\_internet\_ingestion\_enabled) | Whether or not internet ingestion is enabled for the Log Analytics Workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_internet_query_enabled"></a> [log\_analytics\_workspace\_internet\_query\_enabled](#input\_log\_analytics\_workspace\_internet\_query\_enabled) | Whether or not internet query is enabled for the Log Analytics Workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_local_authentication_enabled"></a> [log\_analytics\_workspace\_local\_authentication\_enabled](#input\_log\_analytics\_workspace\_local\_authentication\_enabled) | Whether or not local authentication is enabled for the Log Analytics Workspace. | `bool` | `true` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | The name of the Log Analytics Workspace to create. | `string` | `null` | no |
| <a name="input_log_analytics_workspace_reservation_capacity_in_gb_per_day"></a> [log\_analytics\_workspace\_reservation\_capacity\_in\_gb\_per\_day](#input\_log\_analytics\_workspace\_reservation\_capacity\_in\_gb\_per\_day) | The reservation capacity in GB per day for the Log Analytics Workspace. | `number` | `null` | no |
| <a name="input_log_analytics_workspace_retention_in_days"></a> [log\_analytics\_workspace\_retention\_in\_days](#input\_log\_analytics\_workspace\_retention\_in\_days) | The number of days to retain data for the Log Analytics Workspace. | `number` | `30` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | The SKU to use for the Log Analytics Workspace. | `string` | `"PerGB2018"` | no |
| <a name="input_parent_resource_id"></a> [parent\_resource\_id](#input\_parent\_resource\_id) | Parent management group name. Leave empty to target tenant root group. | `string` | `""` | no |
| <a name="input_platform_subscriptions"></a> [platform\_subscriptions](#input\_platform\_subscriptions) | A map of platform subscription definitions keyed by a stable subscription instance name.<br/><br/>Use this to pass one or more subscription definitions into a module with `for_each`:<pre>terraform<br/>module "platform_subscriptions" {<br/>  source   = "./modules/platform_subscriptions"<br/>  for_each = var.platform_subscriptions<br/><br/>  subscription_alias_enabled                        = each.value.subscription_alias_enabled<br/>  subscription_alias_name                           = each.value.subscription_alias_name<br/>  subscription_billing_scope                        = each.value.subscription_billing_scope<br/>  subscription_display_name                         = each.value.subscription_display_name<br/>  subscription_id                                   = each.value.subscription_id<br/>  subscription_management_group_association_enabled = each.value.subscription_management_group_association_enabled<br/>  subscription_management_group_id                  = each.value.subscription_management_group_id<br/>  subscription_tags                                 = each.value.subscription_tags<br/>  subscription_update_existing                      = each.value.subscription_update_existing<br/>  subscription_workload                             = each.value.subscription_workload<br/>  wait_for_subscription_before_subscription_operations = each.value.wait_for_subscription_before_subscription_operations<br/>}</pre>When `subscription_alias_enabled` is `true`, supply:<br/><br/>- `subscription_alias_name`<br/>- `subscription_display_name`<br/>- `subscription_billing_scope`<br/>- `subscription_workload`<br/><br/>Optionally, supply the following to place the subscription into a management group:<br/><br/>- `subscription_management_group_id`<br/>- `subscription_management_group_association_enabled`<br/><br/>When `subscription_alias_enabled` is `false`, supply `subscription_id` to use an existing subscription instead.<br/><br/>When using an existing subscription and managing management group membership, set `subscription_management_group_association_enabled` to `true` and supply `subscription_management_group_id`.<br/><br/>Set `subscription_update_existing` to `true` to update an existing subscription with the supplied tags and display name. When enabled, `subscription_id` must also be supplied.<br/><br/>`subscription_workload` can be either `Production` or `DevTest` and is case sensitive.<br/><br/>`wait_for_subscription_before_subscription_operations` controls the duration to wait after vending a subscription before performing subscription operations. | <pre>map(object({<br/>    subscription_alias_enabled                        = optional(bool, false)<br/>    subscription_alias_name                           = optional(string)<br/>    subscription_billing_scope                        = optional(string)<br/>    subscription_display_name                         = optional(string)<br/>    subscription_id                                   = optional(string)<br/>    subscription_management_group_association_enabled = optional(bool, false)<br/>    subscription_management_group_id                  = optional(string)<br/>    subscription_tags                                 = optional(map(string), {})<br/>    subscription_update_existing                      = optional(bool, false)<br/>    subscription_workload                             = optional(string)<br/>    wait_for_subscription_before_subscription_operations = optional(object({<br/>      create  = optional(string, "30s")<br/>      destroy = optional(string, "0s")<br/>    }), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_creation_enabled"></a> [resource\_group\_creation\_enabled](#input\_resource\_group\_creation\_enabled) | A boolean flag to determine whether to deploy the Azure Resource Group or not. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Azure Resource Group where the resources will be created. | `string` | n/a | yes |
| <a name="input_sentinel_onboarding"></a> [sentinel\_onboarding](#input\_sentinel\_onboarding) | Enables and customizes the Sentinel onboarding. Default is `null`, which disables Sentinel onboarding.<br/><br/>Set to empty object `{}` to enable with default values.<br/><br/>This is an object with the following attributes:<br/><br/>- name (Optional) - The name of the Sentinel onboarding object. Defaults to `default`.<br/>- customer\_managed\_key\_enabled (Optional) - Whether or not to enable customer-managed keys for the Sentinel onboarding. Defaults to `false`. | <pre>object({<br/>    name                         = optional(string, "default")<br/>    customer_managed_key_enabled = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | `""` | no |
| <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity) | Subscription ID to use for "identity" resources. | `string` | `""` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | `""` | no |
| <a name="input_subscription_id_security"></a> [subscription\_id\_security](#input\_subscription\_id\_security) | Subscription ID to use for "security" resources. | `string` | `""` | no |
| <a name="input_subscription_placement_destroy_behavior"></a> [subscription\_placement\_destroy\_behavior](#input\_subscription\_placement\_destroy\_behavior) | The destroy behavior for subscription placements. Valid values are 'default', 'parent', 'intermediate\_root' or 'custom'. | `string` | `"parent"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to the resources created. | `map(string)` | `null` | no |
| <a name="input_user_assigned_managed_identities"></a> [user\_assigned\_managed\_identities](#input\_user\_assigned\_managed\_identities) | Enables customisation of the user assigned managed identities.<br/><br/>The value of this variable is an object with the following attributes:<br/><br/>- ama (Required) - The user assigned managed identity for the Azure Monitor Agent.<br/>  - enabled (Optional) - Whether or not to create the user assigned managed identity. Defaults to `true`.<br/>  - name (Required) - The name of the user assigned managed identity, the variable default value is `uami-ama`.<br/>  - location (Optional) - The Azure region of the user assigned managed identity. Defaults to the value of the location variable.<br/>  - tags (Optional) - A map of tags to apply to the user assigned managed identity. Defaults to `null`. | <pre>object({<br/>    ama = object({<br/>      enabled  = optional(bool, true)<br/>      name     = string<br/>      location = optional(string, null)<br/>      tags     = optional(map(string), null)<br/>    })<br/>  })</pre> | <pre>{<br/>  "ama": {<br/>    "name": "uami-ama"<br/>  }<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_group_resource_ids"></a> [management\_group\_resource\_ids](#output\_management\_group\_resource\_ids) | A map of management group names to their resource ids. |
| <a name="output_management_groups"></a> [management\_groups](#output\_management\_groups) | n/a |
| <a name="output_policy_assignment_identity_ids"></a> [policy\_assignment\_identity\_ids](#output\_policy\_assignment\_identity\_ids) | A map of policy assignment names to their identity ids. |
| <a name="output_policy_assignment_resource_ids"></a> [policy\_assignment\_resource\_ids](#output\_policy\_assignment\_resource\_ids) | A map of policy assignment names to their resource ids. |
| <a name="output_policy_definition_resource_ids"></a> [policy\_definition\_resource\_ids](#output\_policy\_definition\_resource\_ids) | A map of policy definition names to their resource ids. |
| <a name="output_policy_role_assignment_resource_ids"></a> [policy\_role\_assignment\_resource\_ids](#output\_policy\_role\_assignment\_resource\_ids) | A map of policy role assignments to their resource ids. |
| <a name="output_policy_set_definition_resource_ids"></a> [policy\_set\_definition\_resource\_ids](#output\_policy\_set\_definition\_resource\_ids) | A map of policy set definition names to their resource ids. |
| <a name="output_role_definition_resource_ids"></a> [role\_definition\_resource\_ids](#output\_role\_definition\_resource\_ids) | A map of role definition names to their resource ids. |
<!-- END_TF_DOCS -->
