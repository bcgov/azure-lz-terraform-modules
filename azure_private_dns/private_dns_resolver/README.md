# private_dns_resolver

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_resolver.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_dns_forwarding_ruleset.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_dns_forwarding_ruleset) | resource |
| [azurerm_private_dns_resolver_forwarding_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_forwarding_rule) | resource |
| [azurerm_private_dns_resolver_inbound_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) | resource |
| [azurerm_private_dns_resolver_outbound_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_forwarding_rules"></a> [forwarding\_rules](#input\_forwarding\_rules) | (Optional) List of forwarding rules to create. Each rule should have name, domain\_name, enabled, and target\_dns\_servers. | <pre>list(object({<br/>    name        = string<br/>    domain_name = string<br/>    enabled     = bool<br/>    target_dns_servers = list(object({<br/>      ip_address = string<br/>      port       = number<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_private_dns_resolver_name"></a> [private\_dns\_resolver\_name](#input\_private\_dns\_resolver\_name) | (Required) Specifies the name which should be used for this Private DNS Resolver. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Specifies the name of the Resource Group where the Private DNS Resolver should exist. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | (Required) Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_virtual_network_object"></a> [virtual\_network\_object](#input\_virtual\_network\_object) | (Required) The Virtual Network object that is linked to the Private DNS Resolver. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_resolver"></a> [private\_dns\_resolver](#output\_private\_dns\_resolver) | The ID of the Private DNS Resolver. |
| <a name="output_private_dns_resolver_dns_forwarding_ruleset"></a> [private\_dns\_resolver\_dns\_forwarding\_ruleset](#output\_private\_dns\_resolver\_dns\_forwarding\_ruleset) | The ID of the Private DNS Resolver DNS Forwarding Ruleset. |
| <a name="output_private_dns_resolver_forwarding_rules"></a> [private\_dns\_resolver\_forwarding\_rules](#output\_private\_dns\_resolver\_forwarding\_rules) | Map of Private DNS Resolver Forwarding Rules. |
| <a name="output_private_dns_resolver_inbound_endpoint"></a> [private\_dns\_resolver\_inbound\_endpoint](#output\_private\_dns\_resolver\_inbound\_endpoint) | The ID of the Private DNS Resolver Inbound Endpoint. |
| <a name="output_private_dns_resolver_outbound_endpoint"></a> [private\_dns\_resolver\_outbound\_endpoint](#output\_private\_dns\_resolver\_outbound\_endpoint) | The ID of the Private DNS Resolver Outbound Endpoint. |
<!-- END_TF_DOCS -->
