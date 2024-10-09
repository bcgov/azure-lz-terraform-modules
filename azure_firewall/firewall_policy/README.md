# firewall_policy_rcg

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.112.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.112.0, < 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_learn_private_ranges_enabled"></a> [auto\_learn\_private\_ranges\_enabled](#input\_auto\_learn\_private\_ranges\_enabled) | (Optional) Whether enable auto learn private IP range. | `bool` | `null` | no |
| <a name="input_base_policy_id"></a> [base\_policy\_id](#input\_base\_policy\_id) | (Optional) The ID of the base Firewall Policy. | `string` | `null` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | (Optional) A dns block as defined below. | <pre>object({<br>    proxy_enabled = optional(bool)<br>    servers       = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_explicit_proxy"></a> [explicit\_proxy](#input\_explicit\_proxy) | (Optional) An explicit\_proxy block as defined below. | <pre>object({<br>    enabled         = optional(bool)<br>    http_port       = optional(number)<br>    https_port      = optional(number)<br>    enable_pac_file = optional(bool)<br>    pac_file_port   = optional(number)<br>    pac_file        = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_firewall_policy_name"></a> [firewall\_policy\_name](#input\_firewall\_policy\_name) | (Required) The name which should be used for this Firewall Policy. | `string` | n/a | yes |
| <a name="input_identity"></a> [identity](#input\_identity) | (Optional) An identity block as defined below. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_insights"></a> [insights](#input\_insights) | (Optional) An insights block as defined below. | <pre>object({<br>    enabled                            = bool<br>    default_log_analytics_workspace_id = string<br>    retention_in_days                  = optional(number)<br>    log_analytics_workspace = optional(list(object({<br>      id                = string<br>      firewall_location = string<br>    })))<br>  })</pre> | `null` | no |
| <a name="input_intrusion_detection"></a> [intrusion\_detection](#input\_intrusion\_detection) | (Optional) A intrusion\_detection block as defined below. | <pre>object({<br>    mode = string<br>    signature_overrides = optional(list(object({<br>      id    = optional(number)<br>      state = optional(string) # Can only be "Off", "Alert", or "Deny"<br>    })))<br>    traffic_bypass = optional(list(object({<br>      name                  = string<br>      protocol              = string<br>      description           = optional(string)<br>      destination_addresses = optional(list(string))<br>      destination_ip_groups = optional(list(string))<br>      destination_ports     = optional(list(string))<br>      source_addresses      = optional(list(string))<br>      source_ip_groups      = optional(list(string))<br>    })))<br>    private_ranges = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure Region where the Firewall Policy should exist. | `string` | n/a | yes |
| <a name="input_private_ip_ranges"></a> [private\_ip\_ranges](#input\_private\_ip\_ranges) | (Optional) A list of private IP ranges to which traffic will not be SNAT. | `list(string)` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group where the Firewall Policy should exist. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | (Optional) The SKU Tier of the Firewall Policy. | `string` | `"Standard"` | no |
| <a name="input_sql_redirect_allowed"></a> [sql\_redirect\_allowed](#input\_sql\_redirect\_allowed) | (Optional) Whether SQL Redirect traffic filtering is allowed. Enabling this flag requires no rule using ports between 11000-11999. | `bool` | `null` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_threat_intelligence_allowlist"></a> [threat\_intelligence\_allowlist](#input\_threat\_intelligence\_allowlist) | (Optional) A threat\_intelligence\_allowlist block as defined below. | <pre>object({<br>    fqdns        = optional(list(string))<br>    ip_addresses = optional(list(string))<br>  })</pre> | `null` | no |
| <a name="input_threat_intelligence_mode"></a> [threat\_intelligence\_mode](#input\_threat\_intelligence\_mode) | (Optional) The operation mode for Threat Intelligence. | `string` | `"Alert"` | no |
| <a name="input_tls_certificate"></a> [tls\_certificate](#input\_tls\_certificate) | (Optional) A tls\_certificate block as defined below. | <pre>object({<br>    key_vault_secret_id = string<br>    name                = string<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_policy_id"></a> [firewall\_policy\_id](#output\_firewall\_policy\_id) | The ID of the Firewall Policy. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
