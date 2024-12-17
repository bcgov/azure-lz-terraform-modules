# Azure Firewall IDPS Signature Rules Overrides

This code is incomplete/work in progress. It is being kept for future reference.

## Of Note

The primary process for using this code is as follows:

1. Run the `idps_signature_rules.sh` script to get all of the IDPS signature rules from Azure Firewall.
  - This will create multiple JSON files (each with up to 1000 rules) in the `idps_signature_rules` directory.
2. Run the `merge_results.sh` script to merge all of the JSON files into a single JSON file.
  - This will create a single JSON file (called `merged_results_formatted.json`) in the `temp` directory.
3. Run the Terraform code, that should read/extract each respective signature rule ID from the merged results, and loop over them, setting the desired **Intrusion Detection** `signatureOverrides` action for each rule.

Additionally, there is some other (incomplete) code that reads the `SampleThreatExport.json` file, extracts the object names, and creates a list of `fqdn_names` and `ip_addresses`. This code would then be used to set the **Threat Intelligence Allow List** (ie. `threatIntelWhitelist`).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.112.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.112.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.fwpolicy_idps](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azapi_update_resource.fwpolicy_threat_intel_allow_list](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/firewall_policy) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_policy_name"></a> [firewall\_policy\_name](#input\_firewall\_policy\_name) | The name of the Azure Firewall Policy. | `string` | n/a | yes |
| <a name="input_firewall_policy_resource_group_name"></a> [firewall\_policy\_resource\_group\_name](#input\_firewall\_policy\_resource\_group\_name) | The name of the resource group in which the Azure Firewall Policy exists. | `string` | n/a | yes |
| <a name="input_idps_private_ip_ranges"></a> [idps\_private\_ip\_ranges](#input\_idps\_private\_ip\_ranges) | (Optional) A list of Private IP address ranges to identify traffic direction. By default, only ranges defined by IANA RFC 1918 are considered private IP addresses. | `list(string)` | `[]` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | n/a |
| <a name="output_fqdn_names"></a> [fqdn\_names](#output\_fqdn\_names) | n/a |
| <a name="output_ip_addresses"></a> [ip\_addresses](#output\_ip\_addresses) | n/a |
| <a name="output_object_names"></a> [object\_names](#output\_object\_names) | List of object names |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
