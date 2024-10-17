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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.116.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.116.0 |
| <a name="provider_azurerm.connectivity"></a> [azurerm.connectivity](#provider\_azurerm.connectivity) | 3.116.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_base_firewall_policy_key_vault"></a> [base\_firewall\_policy\_key\_vault](#module\_base\_firewall\_policy\_key\_vault) | git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_key_vault/key_vault | v0.0.13 |
| <a name="module_base_firewall_policy_key_vault_access_policy"></a> [base\_firewall\_policy\_key\_vault\_access\_policy](#module\_base\_firewall\_policy\_key\_vault\_access\_policy) | git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_key_vault/key_vault_access_policy | v0.0.13 |
| <a name="module_base_firewall_policy_key_vault_certificate"></a> [base\_firewall\_policy\_key\_vault\_certificate](#module\_base\_firewall\_policy\_key\_vault\_certificate) | git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_key_vault/key_vault_certificate | v0.0.13 |
| <a name="module_base_firewall_policy_managed_identity"></a> [base\_firewall\_policy\_managed\_identity](#module\_base\_firewall\_policy\_managed\_identity) | git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_identity/user_assigned_identity | v0.0.13 |
| <a name="module_connectivity"></a> [connectivity](#module\_connectivity) | ./modules/connectivity | n/a |
| <a name="module_core"></a> [core](#module\_core) | ./modules/core | n/a |
| <a name="module_lz_firewall_policy"></a> [lz\_firewall\_policy](#module\_lz\_firewall\_policy) | git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_firewall/firewall_policy | v0.0.13 |
| <a name="module_lz_firewall_policy_rules"></a> [lz\_firewall\_policy\_rules](#module\_lz\_firewall\_policy\_rules) | git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_firewall/firewall_policy_rcg | v0.0.13 |
| <a name="module_management"></a> [management](#module\_management) | ./modules/management | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall_policy.base_firewall_policy](https://registry.terraform.io/providers/hashicorp/azurerm/3.116.0/docs/resources/firewall_policy) | resource |
| [azurerm_resource_group.base_firewall_policy](https://registry.terraform.io/providers/hashicorp/azurerm/3.116.0/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/3.116.0/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | (Optional) The object ID of an Application in Azure Active Directory. | `string` | `null` | no |
| <a name="input_auto_learn_private_ranges_enabled"></a> [auto\_learn\_private\_ranges\_enabled](#input\_auto\_learn\_private\_ranges\_enabled) | (Optional) Whether enable auto learn private IP range. | `bool` | `null` | no |
| <a name="input_base_firewall_policy_name"></a> [base\_firewall\_policy\_name](#input\_base\_firewall\_policy\_name) | (Required) The name which should be used for the parent Firewall Policy. | `string` | n/a | yes |
| <a name="input_base_firewall_policy_rule_collection_group"></a> [base\_firewall\_policy\_rule\_collection\_group](#input\_base\_firewall\_policy\_rule\_collection\_group) | The Azure Firewall Policy Rule Collection Group. | <pre>list(object({<br>    name     = string<br>    priority = number<br><br>    application_rule_collection = optional(list(object({<br>      name     = string<br>      action   = string<br>      priority = number<br>      rule = list(object({<br>        name        = string<br>        description = optional(string)<br>        protocols = optional(list(object({<br>          type = string<br>          port = number<br>        })))<br>        http_headers = optional(list(object({<br>          name  = string<br>          value = string<br>        })))<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_urls      = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_fqdn_tags = optional(list(string))<br>        terminate_tls         = optional(bool)<br>        web_categories        = optional(list(string))<br>      }))<br>    })))<br><br>    network_rule_collection = optional(list(object({<br>      name     = string<br>      action   = string<br>      priority = number<br><br>      rule = list(object({<br>        name                  = string<br>        description           = optional(string)<br>        protocols             = optional(list(string))<br>        destination_ports     = list(string)<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_ip_groups = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>      }))<br>    })))<br><br>    nat_rule_collection = optional(list(object({<br>      name     = string<br>      action   = string<br>      priority = number<br><br>      rule = object({<br>        name                = string<br>        description         = optional(string)<br>        protocols           = list(string)<br>        source_addresses    = optional(list(string))<br>        source_ip_groups    = optional(list(string))<br>        destination_address = optional(string)<br>        destination_ports   = optional(list(string))<br>        translated_address  = optional(string)<br>        translated_fqdn     = optional(string)<br>        translated_port     = string<br>      })<br>    })))<br>  }))</pre> | `null` | no |
| <a name="input_base_policy_id"></a> [base\_policy\_id](#input\_base\_policy\_id) | (Optional) The ID of the base Firewall Policy. | `string` | `null` | no |
| <a name="input_certificate"></a> [certificate](#input\_certificate) | (Optional) A certificate block as defined below, used to Import an existing certificate. | <pre>object({<br>    contents = string<br>    password = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_certificate_name"></a> [certificate\_name](#input\_certificate\_name) | (Required) Specifies the name of the Key Vault Certificate. | `string` | n/a | yes |
| <a name="input_certificate_permissions"></a> [certificate\_permissions](#input\_certificate\_permissions) | (Optional) List of certificate permissions. | `list(string)` | `[]` | no |
| <a name="input_connectivity_resources_tags"></a> [connectivity\_resources\_tags](#input\_connectivity\_resources\_tags) | Specify tags to add to "connectivity" resources. | `map(string)` | <pre>{<br>  "demo_type": "Deploy connectivity resources using multiple module declarations",<br>  "deployedBy": "terraform/azure/caf-enterprise-scale/examples/l400-multi"<br>}</pre> | no |
| <a name="input_contacts"></a> [contacts](#input\_contacts) | (Optional) One or more contact block as defined below. | <pre>list(object({<br>    email = string<br>    name  = optional(string)<br>    phone = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | (Optional) A dns block as defined below. | <pre>object({<br>    proxy_enabled = optional(bool)<br>    servers       = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_email_security_contact"></a> [email\_security\_contact](#input\_email\_security\_contact) | Set a custom value for the security contact email address. | `string` | `"test.user@replace_me"` | no |
| <a name="input_enable_ddos_protection"></a> [enable\_ddos\_protection](#input\_enable\_ddos\_protection) | Controls whether to create a DDoS Network Protection plan and link to hub virtual networks. | `bool` | `false` | no |
| <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization) | (Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. | `bool` | `false` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | (Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | (Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. | `bool` | `false` | no |
| <a name="input_explicit_proxy"></a> [explicit\_proxy](#input\_explicit\_proxy) | (Optional) An explicit\_proxy block as defined below. | <pre>object({<br>    enabled         = optional(bool)<br>    http_port       = optional(number)<br>    https_port      = optional(number)<br>    enable_pac_file = optional(bool)<br>    pac_file_port   = optional(number)<br>    pac_file        = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | (Optional) An identity block as defined below. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_insights"></a> [insights](#input\_insights) | (Optional) An insights block as defined below. | <pre>object({<br>    enabled                            = bool<br>    default_log_analytics_workspace_id = string<br>    retention_in_days                  = optional(number)<br>    log_analytics_workspace = optional(list(object({<br>      id                = string<br>      firewall_location = string<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_intrusion_detection"></a> [intrusion\_detection](#input\_intrusion\_detection) | (Optional) A intrusion\_detection block as defined below. | <pre>object({<br>    mode = string<br>    signature_overrides = optional(list(object({<br>      id    = optional(number)<br>      state = optional(string)<br>    })))<br>    traffic_bypass = optional(list(object({<br>      name                  = string<br>      protocol              = string<br>      description           = optional(string)<br>      destination_addresses = optional(list(string))<br>      destination_ip_groups = optional(list(string))<br>      destination_ports     = optional(list(string))<br>      source_addresses      = optional(list(string))<br>      source_ip_groups      = optional(list(string))<br>    })))<br>    private_ranges = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_key_permissions"></a> [key\_permissions](#input\_key\_permissions) | (Optional) List of key permissions. | `list(string)` | `[]` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | (Required) Specifies the name of the Key Vault Key. | `string` | n/a | yes |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Set a custom value for how many days to store logs in the Log Analytics workspace. | `number` | `60` | no |
| <a name="input_lz_firewall_policy_name"></a> [lz\_firewall\_policy\_name](#input\_lz\_firewall\_policy\_name) | (Required) The name which should be used for the child Firewall Policy. | `string` | n/a | yes |
| <a name="input_lz_firewall_policy_rule_collection_group"></a> [lz\_firewall\_policy\_rule\_collection\_group](#input\_lz\_firewall\_policy\_rule\_collection\_group) | The Azure Firewall Policy Rule Collection Group. | <pre>list(object({<br>    name     = string<br>    priority = number<br><br>    application_rule_collection = optional(list(object({<br>      name     = string<br>      action   = string<br>      priority = number<br>      rule = list(object({<br>        name        = string<br>        description = optional(string)<br>        protocols = optional(list(object({<br>          type = string<br>          port = number<br>        })))<br>        http_headers = optional(list(object({<br>          name  = string<br>          value = string<br>        })))<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_urls      = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>        destination_fqdn_tags = optional(list(string))<br>        terminate_tls         = optional(bool)<br>        web_categories        = optional(list(string))<br>      }))<br>    })))<br><br>    network_rule_collection = optional(list(object({<br>      name     = string<br>      action   = string<br>      priority = number<br><br>      rule = list(object({<br>        name                  = string<br>        description           = optional(string)<br>        protocols             = optional(list(string))<br>        destination_ports     = list(string)<br>        source_addresses      = optional(list(string))<br>        source_ip_groups      = optional(list(string))<br>        destination_addresses = optional(list(string))<br>        destination_ip_groups = optional(list(string))<br>        destination_fqdns     = optional(list(string))<br>      }))<br>    })))<br><br>    nat_rule_collection = optional(list(object({<br>      name     = string<br>      action   = string<br>      priority = number<br><br>      rule = object({<br>        name                = string<br>        description         = optional(string)<br>        protocols           = list(string)<br>        source_addresses    = optional(list(string))<br>        source_ip_groups    = optional(list(string))<br>        destination_address = optional(string)<br>        destination_ports   = optional(list(string))<br>        translated_address  = optional(string)<br>        translated_fqdn     = optional(string)<br>        translated_port     = string<br>      })<br>    })))<br>  }))</pre> | `null` | no |
| <a name="input_management_resources_tags"></a> [management\_resources\_tags](#input\_management\_resources\_tags) | Specify tags to add to "management" resources. | `map(string)` | <pre>{<br>  "demo_type": "Deploy management resources using multiple module declarations",<br>  "deployedBy": "terraform/azure/caf-enterprise-scale/examples/l400-multi"<br>}</pre> | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | (Optional) A network\_acls block as defined below. | <pre>object({<br>    bypass                     = string<br>    default_action             = string<br>    ip_rules                   = list(string)<br>    virtual_network_subnet_ids = list(string)<br>  })</pre> | `null` | no |
| <a name="input_primary_location"></a> [primary\_location](#input\_primary\_location) | Sets the location for "primary" resources to be created in. | `string` | `"CanadaCentral"` | no |
| <a name="input_private_ip_ranges"></a> [private\_ip\_ranges](#input\_private\_ip\_ranges) | (Optional) A list of private IP ranges to which traffic will not be SNAT. | `list(string)` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | (Optional) Whether public network access is allowed for this Key Vault. | `bool` | `false` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | (Optional) Is Purge Protection enabled for this Key Vault? | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the resource group in which to create the Key Vault. | `string` | n/a | yes |
| <a name="input_root_id"></a> [root\_id](#input\_root\_id) | Sets the value used for generating unique resource naming within the module. | `string` | `"myorg"` | no |
| <a name="input_root_name"></a> [root\_name](#input\_root\_name) | Sets the value used for the "intermediate root" management group display name. | `string` | `"My Organization"` | no |
| <a name="input_root_parent_id"></a> [root\_parent\_id](#input\_root\_parent\_id) | Sets the value for the parent management group. | `string` | `""` | no |
| <a name="input_secondary_location"></a> [secondary\_location](#input\_secondary\_location) | Sets the location for "secondary" resources to be created in. | `string` | `"CanadaEast"` | no |
| <a name="input_secret_permissions"></a> [secret\_permissions](#input\_secret\_permissions) | (Optional) List of secret permissions. | `list(string)` | `[]` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | (Optional) The SKU Tier of the Firewall Policy. | `string` | `"Standard"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | (Required) The Name of the SKU used for this Key Vault. | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | (Optional) The number of days that items should be retained for once soft-deleted. | `number` | `7` | no |
| <a name="input_sql_redirect_allowed"></a> [sql\_redirect\_allowed](#input\_sql\_redirect\_allowed) | (Optional) Whether SQL Redirect traffic filtering is allowed. Enabling this flag requires no rule using ports between 11000-11999. | `bool` | `null` | no |
| <a name="input_storage_permissions"></a> [storage\_permissions](#input\_storage\_permissions) | (Optional) List of storage permissions. | `list(string)` | `[]` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | `""` | no |
| <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity) | Subscription ID to use for "identity" resources. | `string` | `""` | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | `""` | no |
| <a name="input_threat_intelligence_allowlist"></a> [threat\_intelligence\_allowlist](#input\_threat\_intelligence\_allowlist) | (Optional) A threat\_intelligence\_allowlist block as defined below. | <pre>object({<br>    fqdns        = optional(list(string))<br>    ip_addresses = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_threat_intelligence_mode"></a> [threat\_intelligence\_mode](#input\_threat\_intelligence\_mode) | (Optional) The operation mode for Threat Intelligence. | `string` | `"Alert"` | no |
| <a name="input_tls_certificate"></a> [tls\_certificate](#input\_tls\_certificate) | (Optional) A tls\_certificate block as defined below. | <pre>object({<br>    key_vault_secret_id = string<br>    name                = string<br>  })</pre> | `null` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | (Required) Specifies the name of this User Assigned Identity. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_base_firewall_policy"></a> [base\_firewall\_policy](#output\_base\_firewall\_policy) | The base Azure Firewall Policy object. |
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | The Azure Firewall Policy ID. |
| <a name="output_identity_id"></a> [identity\_id](#output\_identity\_id) | The ID of the User Assigned Identity. |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault. |
| <a name="output_lz_firewall_policy"></a> [lz\_firewall\_policy](#output\_lz\_firewall\_policy) | The base Azure Firewall Policy object. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
