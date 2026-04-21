# core

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alz"></a> [alz](#module\_alz) | Azure/caf-enterprise-scale/azurerm | 6.3.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.116.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_VNet-DNS-Settings"></a> [VNet-DNS-Settings](#input\_VNet-DNS-Settings) | Sets the VNet DNS settings for the policy assignment. | `list(any)` | n/a | yes |
| <a name="input_aks_security_best_prac_parameters"></a> [aks\_security\_best\_prac\_parameters](#input\_aks\_security\_best\_prac\_parameters) | Parameter values for the AKS-Security-BestPrac initiative assignment. | <pre>object({<br/>    enforce_azure_cni_overlay    = string<br/>    enforce_entra_id_integration = string<br/>    enforce_kubernetes_rbac      = string<br/>    enforce_azure_rbac           = string<br/>    enforce_disable_local_auth   = string<br/>    enforce_workload_identity    = string<br/>    enforce_managed_identity     = string<br/>    enforce_oidc_issuer          = string<br/>    enforce_secrets_store_csi    = string<br/>    enforce_acns_security        = string<br/>    enforce_cilium_dataplane     = string<br/>    audit_azure_policy_addon     = string<br/>    deploy_azure_policy_addon    = string<br/>    deploy_image_cleaner         = string<br/>    audit_image_cleaner          = string<br/>  })</pre> | n/a | yes |
| <a name="input_configure_connectivity_resources"></a> [configure\_connectivity\_resources](#input\_configure\_connectivity\_resources) | Configuration settings for "connectivity" resources. | `any` | n/a | yes |
| <a name="input_configure_management_resources"></a> [configure\_management\_resources](#input\_configure\_management\_resources) | Configuration settings for "management" resources. | `any` | n/a | yes |
| <a name="input_country_location"></a> [country\_location](#input\_country\_location) | Sets the country location. Used by some Azure resources taht are not tied to the regions. | `string` | n/a | yes |
| <a name="input_enforce_aks_cidrs_parameters"></a> [enforce\_aks\_cidrs\_parameters](#input\_enforce\_aks\_cidrs\_parameters) | Parameter values for the Enforce-AKS-CIDRs policy assignment. | <pre>object({<br/>    allowedPodCidrRanges     = list(string)<br/>    enforceServiceCidr       = bool<br/>    allowedServiceCidrRanges = list(string)<br/>    effect                   = string<br/>  })</pre> | n/a | yes |
| <a name="input_enforce_private_cluster"></a> [enforce\_private\_cluster](#input\_enforce\_private\_cluster) | Parameter value for the Enforce-AKS-Private-Cluster policy assignment. | <pre>object({<br/>    effect = string<br/>  })</pre> | n/a | yes |
| <a name="input_network_watcher_storage_account_name"></a> [network\_watcher\_storage\_account\_name](#input\_network\_watcher\_storage\_account\_name) | The Storage Account name used for Network Watcher VNet Flow Logs. | `string` | n/a | yes |
| <a name="input_network_watcher_storage_account_resource_group"></a> [network\_watcher\_storage\_account\_resource\_group](#input\_network\_watcher\_storage\_account\_resource\_group) | The Resource Group of the Storage Account used for Network Watcher VNet Flow Logs. | `string` | n/a | yes |
| <a name="input_nsp_name"></a> [nsp\_name](#input\_nsp\_name) | Name of the Network Security Perimeter (NSP) to associate resources with. | `string` | `""` | no |
| <a name="input_nsp_profile"></a> [nsp\_profile](#input\_nsp\_profile) | Name of the NSP profile. | `string` | `""` | no |
| <a name="input_nsp_resource_group_name"></a> [nsp\_resource\_group\_name](#input\_nsp\_resource\_group\_name) | Resource group name where the Network Security Perimeter (NSP) exists. | `string` | `""` | no |
| <a name="input_nsp_subscription_id"></a> [nsp\_subscription\_id](#input\_nsp\_subscription\_id) | Subscription ID where the Network Security Perimeter (NSP) exists. | `string` | `""` | no |
| <a name="input_policy_effect"></a> [policy\_effect](#input\_policy\_effect) | Sets the effect for the policy assignment. | `string` | `null` | no |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | Sets the location for "primary" resources to be created in. | `string` | n/a | yes |
| <a name="input_root_id"></a> [root\_id](#input\_root\_id) | Sets the value used for generating unique resource naming within the module. | `string` | n/a | yes |
| <a name="input_root_name"></a> [root\_name](#input\_root\_name) | Sets the value used for the "intermediate root" management group display name. | `string` | n/a | yes |
| <a name="input_root_parent_id"></a> [root\_parent\_id](#input\_root\_parent\_id) | Sets the value for the parent management group. | `string` | n/a | yes |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | Sets the location for "secondary" resources to be created in. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity) | Subscription ID to use for "identity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
