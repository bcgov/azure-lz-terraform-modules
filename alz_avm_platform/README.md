# ALZ AVM Platform Lessons Learned

1. We need `Owner` permissons on the subscriptions that will be moved into the new Management Group hierarchy.

- Error: `"Permission to write and delete on resources of type 'Microsoft.Authorization/roleAssignments' is required on the subscription or its ancestors."`

2. Despite the Azure Landing Zone documentation (https://azure.github.io/Azure-Landing-Zones/terraform/custom-policy/policy-assignment/) stating that YAML is a valid format for Policy Definitions, Policy Sets, and Policy Assignments, based on the following GitHub issues, the format MUST be in JSON:
   - [[Bug]: alzlib - YAML role definition files fail to parse due to yaml.v3 ignoring json struct tags](https://github.com/Azure/Azure-Landing-Zones/issues/4225)
     - Comment points to this PR: [docs: correct supported file formats for library assets](https://github.com/Azure/Azure-Landing-Zones-Library/pull/340)

3. After deploying the AMBA policies, remediation needs to be triggered to create the Activity Log, Log Search, and Metric alert rules.
  - NOTE: Specific `Resource Providers` need to be registered for the various subscriptions for the remediation to work.
  - `Microsoft.AlertsManagement`
  - `Microsoft.Insights`
  - NOTE: Added to the platform_subscriptions module
  - Not all Alert rules have been successfully created in the AVM management subscription

4. Additional policies need to be remediated. Examples:
  - Deploy Microsoft Defender for Cloud Security Contacts
  - Deploy export to Log Analytics workspace for Microsoft Defender for Cloud data
  - Configure Azure Activity logs to stream to specified Log Analytics workspace
  - Configure subscriptions to enable service health alert monitoring rule
  - Configure Microsoft Defender threat protection for AI Services
  - Enable logging by category group for Log Analytics workspaces (microsoft.operationalinsights/workspaces) to Log Analytics
  - Enable logging by category group for Automation Accounts (microsoft.automation/automationaccounts) to Log Analytics
  - Setup subscriptions to transition to an alternative vulnerability assessment solution

5. Location property for vWAN must be like ... else, the following error is thrown:
  > for key, value in var.virtual_hubs : key => module.regions[0].regions_by_name[value.location].zones == null ? [] : module.regions[0].regions_by_name[value.location].zones
  > │     ├────────────────
  > │     │ module.regions[0].regions_by_name is object with 63 attributes
  > │     │ value.location is "Canada Central"
  > │
  > │ The given key does not identify an element in this collection value.

6. vWAN cannot be deployed without including the deployment of a vHub, because the `avm-ptn-alz-connectivity-virtual-wan` module gates the entire `virtual_wan` submodule (the one that actually creates `azurerm_virtual_wan`) on `count = local.has_regions ? 1 : 0`, where `has_regions = length(var.virtual_hubs) > 0`. This module ties the VWAN's location/resource group to its primary hub, so a standalone vWAN with zero hubs isn't supported.

7. The `avm-ptn-alz-connectivity-virtual-wan` module does not expose a property to control the virtual hub private traffix additional prefixes.

8. The `avm-ptn-alz-connectivity-virtual-wan` module supports one sidecar VNet per Virtual Hub, but that VNet is intended to host multiple service-specific subnets.

9. Defining the Private DNS Resolver inbound subnet must be done via the `private_dns_resolver.inbound_endpoints` block, instead of through the `sidecar_virtual_network.subnets` block (like the `outbound_endpoints`) because the `private_dns_resolver` block always creates the inbound subnet when the resolver is enabled.
   - That's an unavoidable side effect of the module always creating it when the resolver is enabled, not something we can suppress via config.
   - This also prevents including the creation and association of a Network Security Group for the inbound subnet.

10. The default private dns zones deployed include the zones we've had to create custom in the CAF, namely:
    - azure_container_apps → `privatelink.{regionName}.azurecontainerapps.io`
    - azure_ai_services → `privatelink.services.ai.azure.com`
    - azure_managed_redis → `privatelink.redis.azure.net`
    - azure_fabric → `privatelink.fabric.microsoft.com`

## TO DO

### Management Subscription

- [x] Create Network Manager / IP Address Pool
  - NOTE: There is only a "proposed" AVM module for `avm-ptn-azure-ipam`
- [ ] Independent deployment of Network Flow Logs storage

### AMBA

- [ ] Customize AMBA policy assignments, so that the root MG does not include alert rules we don't want to affect the Landing Zones (use our existing customizations as a reference)


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
| <a name="module_amba"></a> [amba](#module\_amba) | ./modules/amba | n/a |
| <a name="module_connectivity"></a> [connectivity](#module\_connectivity) | ./modules/connectivity | n/a |
| <a name="module_management_groups"></a> [management\_groups](#module\_management\_groups) | ./modules/management_groups | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_client_config.current](https://registry.terraform.io/providers/Azure/azapi/latest/docs/data-sources/client_config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amba"></a> [amba](#output\_amba) | n/a |
| <a name="output_connectivity"></a> [connectivity](#output\_connectivity) | n/a |
| <a name="output_management_groups"></a> [management\_groups](#output\_management\_groups) | n/a |
<!-- END_TF_DOCS -->
