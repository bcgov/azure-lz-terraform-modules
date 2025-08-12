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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 1.13, != 1.13.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.112.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.vwan_routing_intent_and_policies](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_resource_id"></a> [firewall\_resource\_id](#input\_firewall\_resource\_id) | Resource ID of the Azure Firewall. | `string` | n/a | yes |
| <a name="input_onpremises_address_ranges"></a> [onpremises\_address\_ranges](#input\_onpremises\_address\_ranges) | List of on-premises address ranges. | `list(string)` | n/a | yes |
| <a name="input_rfc_1918_address_ranges"></a> [rfc\_1918\_address\_ranges](#input\_rfc\_1918\_address\_ranges) | List of RFC 1918 address ranges. | `list(string)` | <pre>[<br/>  "10.0.0.0/8",<br/>  "172.16.0.0/12",<br/>  "192.168.0.0/16",<br/>  "100.64.0.0/10"<br/>]</pre> | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_vhub_resource_id"></a> [vhub\_resource\_id](#input\_vhub\_resource\_id) | Resource ID of the Virtual Hub. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
