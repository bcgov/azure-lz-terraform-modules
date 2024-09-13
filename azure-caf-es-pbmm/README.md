# Azure Cloud Adoption Framework Enterprise Scale (PBMM) Terraform Module

## Policies and Policy Sets

The following policies are applied in this implementation at the root of the landing zone.
It is be possible to move some management activity outside the policy scope by moving the application to the "Landing zone" management group instead of the root.

1. Canada Fedral PBMM
2. Location Restrictions to only Canada Central and Canada East
3. NIST SP 800-53 Rev. 5
4. Microsoft cloud security benchmark (Azure Security Benchmark used in CanPubSecALZ is deprecated)
5. CIS Microsoft Azure Foundations Benchmark v2.0.0
6. FedRAMP Moderate
7. HITRUST/HIPAA (not configured fully yet)

Policies are applied in the "Default" mode. It should be possible to provide [overrides](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2024-04-01/policyassignments?pivots=deployment-language-terraform) when needed.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.108.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.108.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_connectivity"></a> [connectivity](#module\_connectivity) | ./modules/connectivity | n/a |
| <a name="module_core"></a> [core](#module\_core) | ./modules/core | n/a |
| <a name="module_management"></a> [management](#module\_management) | ./modules/management | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.108.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_connectivity_resources_tags"></a> [connectivity\_resources\_tags](#input\_connectivity\_resources\_tags) | Specify tags to add to "connectivity" resources. | `map(string)` | <pre>{<br>  "demo_type": "Deploy connectivity resources using multiple module declarations",<br>  "deployedBy": "terraform/azure/caf-enterprise-scale/examples/l400-multi"<br>}</pre> | no |
| <a name="input_email_security_contact"></a> [email\_security\_contact](#input\_email\_security\_contact) | Set a custom value for the security contact email address. | `string` | `"test.user@replace_me"` | no |
| <a name="input_enable_ddos_protection"></a> [enable\_ddos\_protection](#input\_enable\_ddos\_protection) | Controls whether to create a DDoS Network Protection plan and link to hub virtual networks. | `bool` | `false` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Set a custom value for how many days to store logs in the Log Analytics workspace. | `number` | `60` | no |
| <a name="input_management_resources_tags"></a> [management\_resources\_tags](#input\_management\_resources\_tags) | Specify tags to add to "management" resources. | `map(string)` | <pre>{<br>  "demo_type": "Deploy management resources using multiple module declarations",<br>  "deployedBy": "terraform/azure/caf-enterprise-scale/examples/l400-multi"<br>}</pre> | no |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | Sets the location for "primary" resources to be created in. | `string` | `"CanadaCentral"` | no |
| <a name="input_root_id"></a> [root\_id](#input\_root\_id) | Sets the value used for generating unique resource naming within the module. | `string` | `"myorg"` | no |
| <a name="input_root_name"></a> [root\_name](#input\_root\_name) | Sets the value used for the "intermediate root" management group display name. | `string` | `"My Organization"` | no |
| <a name="input_root_parent_id"></a> [root\_parent\_id](#input\_root\_parent\_id) | Sets the value for the parent management group. | `string` | `""` | no |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | Sets the location for "secondary" resources to be created in. | `string` | `"CanadaEast"` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | `""` | no |
| <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity) | Subscription ID to use for "identity" resources. | `string` | `""` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | `""` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
