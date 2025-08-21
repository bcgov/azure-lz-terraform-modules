# dns_forwarding_ruleset_virtual_network_link

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.dns_forwarding_ruleset_virtual_network_link](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_forwarding_ruleset_id"></a> [dns\_forwarding\_ruleset\_id](#input\_dns\_forwarding\_ruleset\_id) | The ID of the DNS Forwarding Ruleset to which the virtual network link will be added. | `string` | n/a | yes |
| <a name="input_link_name"></a> [link\_name](#input\_link\_name) | The name of the DNS Forwarding Ruleset Virtual Network Link. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | (Required) Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_virtual_network_object"></a> [virtual\_network\_object](#input\_virtual\_network\_object) | (Required) The Virtual Network object that is linked to the Private DNS Resolver. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_forwarding_ruleset_virtual_network_link"></a> [dns\_forwarding\_ruleset\_virtual\_network\_link](#output\_dns\_forwarding\_ruleset\_virtual\_network\_link) | The DNS Forwarding Ruleset Virtual Network Link resource. |
<!-- END_TF_DOCS -->
