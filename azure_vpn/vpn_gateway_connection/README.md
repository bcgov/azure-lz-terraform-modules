# vpn_gateway_connection

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
| [azurerm_vpn_gateway_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway_connection) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_vpn_gateway_connection"></a> [vpn\_gateway\_connection](#input\_vpn\_gateway\_connection) | n/a | <pre>list(object({<br/>    vpn_gateway_connection_name = string<br/>    resource_group_name         = string<br/>    location                    = string<br/>    remote_vpn_site_id          = string<br/>    vpn_gateway_id              = string<br/>    vpn_link = list(object({<br/>      name                 = string<br/>      egress_nat_rule_ids  = optional(list(string))<br/>      ingress_nat_rule_ids = optional(list(string))<br/>      vpn_site_link_id     = string<br/>      bandwidth_mbps       = optional(number)<br/>      bgp_enabled          = optional(bool)<br/>      connection_mode      = optional(string)<br/>      ipsec_policy = optional(list(object({<br/>        dh_group                 = string<br/>        ike_encryption_algorithm = string<br/>        ike_integrity_algorithm  = string<br/>        encryption_algorithm     = string<br/>        integrity_algorithm      = string<br/>        pfs_group                = string<br/>        sa_data_size_kb          = number<br/>        sa_lifetime_sec          = number<br/>      })))<br/>      protocol                              = optional(string)<br/>      ratelimit_enabled                     = optional(bool)<br/>      route_weight                          = optional(number)<br/>      shared_key                            = optional(string)<br/>      local_azure_ip_address_enabled        = optional(bool)<br/>      policy_based_traffic_selector_enabled = optional(bool)<br/>      custom_bgp_address = optional(list(object({<br/>        ip_address          = string<br/>        ip_configuration_id = string<br/>      })))<br/>    }))<br/>    internet_security_enabled = optional(bool)<br/>    routing = optional(object({<br/>      associated_route_table = string<br/>      propagated_route_table = optional(object({<br/>        route_table_ids = list(string)<br/>        labels          = optional(list(string))<br/>      }))<br/>      inbound_route_map_id  = optional(string)<br/>      outbound_route_map_id = optional(string)<br/>    }))<br/>    traffic_selector_policy = optional(list(object({<br/>      local_address_ranges  = list(string)<br/>      remote_address_ranges = list(string)<br/>    })))<br/>    tags = optional(map(string))<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpn_gateway_connection_ids"></a> [vpn\_gateway\_connection\_ids](#output\_vpn\_gateway\_connection\_ids) | A map of VPN Gateway Connection IDs keyed by their names. |
| <a name="output_vpn_gateway_connection_internet_security_enabled"></a> [vpn\_gateway\_connection\_internet\_security\_enabled](#output\_vpn\_gateway\_connection\_internet\_security\_enabled) | A map indicating if Internet Security is enabled for each VPN Gateway Connection, keyed by their names. |
| <a name="output_vpn_gateway_connection_names"></a> [vpn\_gateway\_connection\_names](#output\_vpn\_gateway\_connection\_names) | A list of VPN Gateway Connection names. |
| <a name="output_vpn_gateway_connection_remote_vpn_site_ids"></a> [vpn\_gateway\_connection\_remote\_vpn\_site\_ids](#output\_vpn\_gateway\_connection\_remote\_vpn\_site\_ids) | A map of Remote VPN Site IDs keyed by VPN Gateway Connection names. |
| <a name="output_vpn_gateway_connection_routings"></a> [vpn\_gateway\_connection\_routings](#output\_vpn\_gateway\_connection\_routings) | A map of Routing configurations keyed by VPN Gateway Connection names. |
| <a name="output_vpn_gateway_connection_traffic_selector_policies"></a> [vpn\_gateway\_connection\_traffic\_selector\_policies](#output\_vpn\_gateway\_connection\_traffic\_selector\_policies) | A map of Traffic Selector Policy configurations keyed by VPN Gateway Connection names. |
| <a name="output_vpn_gateway_connection_vpn_gateway_ids"></a> [vpn\_gateway\_connection\_vpn\_gateway\_ids](#output\_vpn\_gateway\_connection\_vpn\_gateway\_ids) | A map of VPN Gateway IDs keyed by VPN Gateway Connection names. |
| <a name="output_vpn_gateway_connection_vpn_links"></a> [vpn\_gateway\_connection\_vpn\_links](#output\_vpn\_gateway\_connection\_vpn\_links) | A map of VPN Link configurations keyed by VPN Gateway Connection names. |
<!-- END_TF_DOCS -->
