# vpn_site

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_vpn_site.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_site) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_vpn_site"></a> [vpn\_site](#input\_vpn\_site) | (Required) A map of VPN Site properties. | <pre>list(object({<br/>    name                = string<br/>    resource_group_name = string<br/>    location            = string<br/>    virtual_wan_id      = string<br/>    link = optional(list(object({<br/>      name = string<br/>      bgp = optional(object({<br/>        asn             = number<br/>        peering_address = string<br/>      }))<br/>      fqdn          = optional(string)<br/>      ip_address    = optional(string)<br/>      provider_name = optional(string)<br/>      speed_in_mbps = optional(number)<br/>    })))<br/>    address_cidrs = optional(list(string))<br/>    device_model  = optional(string)<br/>    device_vendor = optional(string)<br/>    o365_policy = optional(object({<br/>      traffic_category = optional(object({<br/>        allow_endpoint_enabled    = optional(bool)<br/>        default_endpoint_enabled  = optional(bool)<br/>        optimize_endpoint_enabled = optional(bool)<br/>      }))<br/>    }))<br/>    tags = optional(map(string))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_site"></a> [vpn\_site](#output\_vpn\_site) | A map of VPN Sites created. |
<!-- END_TF_DOCS -->
