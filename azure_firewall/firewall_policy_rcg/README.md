# firewall_policy_rcg

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.8.0, < 2.0.0 |
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
| [azurerm_firewall_policy_rule_collection_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy_rule_collection_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_policy_id"></a> [firewall\_policy\_id](#input\_firewall\_policy\_id) | The ID of the Azure Firewall Policy. | `string` | n/a | yes |
| <a name="input_firewall_policy_rule_collection_group"></a> [firewall\_policy\_rule\_collection\_group](#input\_firewall\_policy\_rule\_collection\_group) | The Azure Firewall Policy Rule Collection Group. | <pre>list(object({<br/>    name     = string<br/>    priority = number<br/><br/>    application_rule_collection = optional(list(object({<br/>      name     = string<br/>      action   = string<br/>      priority = number<br/>      rule = list(object({<br/>        name        = string<br/>        description = optional(string)<br/>        protocols = optional(list(object({<br/>          type = string<br/>          port = number<br/>        })))<br/>        http_headers = optional(list(object({<br/>          name  = string<br/>          value = string<br/>        })))<br/>        source_addresses      = optional(list(string))<br/>        source_ip_groups      = optional(list(string))<br/>        destination_addresses = optional(list(string))<br/>        destination_urls      = optional(list(string))<br/>        destination_fqdns     = optional(list(string))<br/>        destination_fqdn_tags = optional(list(string))<br/>        terminate_tls         = optional(bool)<br/>        web_categories        = optional(list(string))<br/>      }))<br/>    })))<br/><br/>    network_rule_collection = optional(list(object({<br/>      name     = string<br/>      action   = string<br/>      priority = number<br/><br/>      rule = list(object({<br/>        name                  = string<br/>        description           = optional(string)<br/>        protocols             = optional(list(string))<br/>        destination_ports     = list(string)<br/>        source_addresses      = optional(list(string))<br/>        source_ip_groups      = optional(list(string))<br/>        destination_addresses = optional(list(string))<br/>        destination_ip_groups = optional(list(string))<br/>        destination_fqdns     = optional(list(string))<br/>      }))<br/>    })))<br/><br/>    nat_rule_collection = optional(list(object({<br/>      name     = string<br/>      action   = string<br/>      priority = number<br/><br/>      rule = object({<br/>        name                = string<br/>        description         = optional(string)<br/>        protocols           = list(string)<br/>        source_addresses    = optional(list(string))<br/>        source_ip_groups    = optional(list(string))<br/>        destination_address = optional(string)<br/>        destination_ports   = optional(list(string))<br/>        translated_address  = optional(string)<br/>        translated_fqdn     = optional(string)<br/>        translated_port     = string<br/>      })<br/>    })))<br/>  }))</pre> | `null` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_policy_rule_collection_group"></a> [firewall\_policy\_rule\_collection\_group](#output\_firewall\_policy\_rule\_collection\_group) | n/a |
<!-- END_TF_DOCS -->
