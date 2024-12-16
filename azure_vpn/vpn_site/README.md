# vpn_site

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| <a name="input_address_cidrs"></a> [address\_cidrs](#input\_address\_cidrs) | (Optional) Specifies a list of IP address CIDRs that are located on your on-premises site. Traffic destined for these address spaces is routed to your local site. | `list(string)` | `null` | no |
| <a name="input_device_model"></a> [device\_model](#input\_device\_model) | (Optional) The model of the VPN device. | `string` | `null` | no |
| <a name="input_device_vendor"></a> [device\_vendor](#input\_device\_vendor) | (Optional) The name of the VPN device vendor. | `string` | `null` | no |
| <a name="input_link"></a> [link](#input\_link) | (Optional) One or more link blocks. | <pre>list(object({<br/>    name = string<br/>    bgp = optional(object({<br/>      asn             = number<br/>      peering_address = string<br/>    }))<br/>    fqdn          = optional(string)<br/>    ip_address    = optional(string)<br/>    provider_name = optional(string)<br/>    speed_in_mbps = optional(number)<br/>  }))</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) The Azure Region where the VPN Site should exist. Changing this forces a new VPN Site to be created. | `string` | n/a | yes |
| <a name="input_o365_policy"></a> [o365\_policy](#input\_o365\_policy) | (Optional) An o365\_policy block. | <pre>object({<br/>    traffic_category = optional(object({<br/>      allow_endpoint_enabled    = optional(bool)<br/>      default_endpoint_enabled  = optional(bool)<br/>      optimize_endpoint_enabled = optional(bool)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) The name of the Resource Group where the VPN Site should exist. Changing this forces a new VPN Site to be created. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_virtual_wan_id"></a> [virtual\_wan\_id](#input\_virtual\_wan\_id) | (Required) The ID of the Virtual Wan where this VPN site resides in. Changing this forces a new VPN Site to be created. | `string` | n/a | yes |
| <a name="input_vpn_site_name"></a> [vpn\_site\_name](#input\_vpn\_site\_name) | (Required) The name which should be used for this VPN Site. Changing this forces a new VPN Site to be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_site_address_cidrs"></a> [vpn\_site\_address\_cidrs](#output\_vpn\_site\_address\_cidrs) | The list of address CIDRs for the VPN Site. |
| <a name="output_vpn_site_device_model"></a> [vpn\_site\_device\_model](#output\_vpn\_site\_device\_model) | The device model for the VPN Site. |
| <a name="output_vpn_site_device_vendor"></a> [vpn\_site\_device\_vendor](#output\_vpn\_site\_device\_vendor) | The device vendor for the VPN Site. |
| <a name="output_vpn_site_id"></a> [vpn\_site\_id](#output\_vpn\_site\_id) | The ID of the VPN Site. |
| <a name="output_vpn_site_link"></a> [vpn\_site\_link](#output\_vpn\_site\_link) | The link block of the VPN Site. |
| <a name="output_vpn_site_name"></a> [vpn\_site\_name](#output\_vpn\_site\_name) | The name of the VPN Site. |
| <a name="output_vpn_site_o365_policy"></a> [vpn\_site\_o365\_policy](#output\_vpn\_site\_o365\_policy) | The O365 policy for the VPN Site. |
| <a name="output_vpn_site_virtual_wan_id"></a> [vpn\_site\_virtual\_wan\_id](#output\_vpn\_site\_virtual\_wan\_id) | The ID of the Virtual WAN that the VPN Site is associated with. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
