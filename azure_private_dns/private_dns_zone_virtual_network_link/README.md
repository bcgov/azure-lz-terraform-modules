# private_dns_zone_virtual_network_link

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_private_dns_zone_virtual_network_link"></a> [private\_dns\_zone\_virtual\_network\_link](#input\_private\_dns\_zone\_virtual\_network\_link) | n/a | <pre>map(object({<br/>    private_dns_zone_vnet_link_name = string<br/>    private_dns_zone_name           = string<br/>    resource_group_name             = string<br/>    virtual_network_id              = string<br/>    registration_enabled            = optional(bool, false)<br/>    resolution_policy               = optional(string, "NxDomainRedirect")<br/>    tags                            = optional(map(string), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vnet-links"></a> [vnet-links](#output\_vnet-links) | A map of Private DNS Zone Virtual Network Link IDs created. |
<!-- END_TF_DOCS -->
