# vpn_gateway_connection

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
| [azurerm_vpn_gateway_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway_connection) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_internet_security_enabled"></a> [internet\_security\_enabled](#input\_internet\_security\_enabled) | (Optional) Whether Internet Security is enabled for this VPN Connection. | `bool` | `false` | no |
| <a name="input_remote_vpn_site_id"></a> [remote\_vpn\_site\_id](#input\_remote\_vpn\_site\_id) | (Required) The ID of the remote VPN Site, which will connect to the VPN Gateway. Changing this forces a new VPN Gateway Connection to be created. | `string` | n/a | yes |
| <a name="input_routing"></a> [routing](#input\_routing) | (Optional) A routing block as defined below. If this is not specified, there will be a default route table created implicitly. | <pre>object({<br/>    associated_route_table = string<br/>    propagated_route_table = optional(object({<br/>      route_table_ids = list(string)<br/>      labels          = optional(list(string))<br/>    }))<br/>    inbound_route_map_id  = optional(string)<br/>    outbound_route_map_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `null` | no |
| <a name="input_traffic_selector_policy"></a> [traffic\_selector\_policy](#input\_traffic\_selector\_policy) | (Optional) One or more traffic\_selector\_policy blocks | <pre>list(object({<br/>    local_address_ranges  = list(string)<br/>    remote_address_ranges = list(string)<br/>  }))</pre> | `null` | no |
| <a name="input_vpn_gateway_connection_name"></a> [vpn\_gateway\_connection\_name](#input\_vpn\_gateway\_connection\_name) | (Required) The name which should be used for this VPN Gateway Connection. Changing this forces a new VPN Gateway Connection to be created. | `string` | n/a | yes |
| <a name="input_vpn_gateway_id"></a> [vpn\_gateway\_id](#input\_vpn\_gateway\_id) | (Required) The ID of the VPN Gateway that this VPN Gateway Connection belongs to. Changing this forces a new VPN Gateway Connection to be created. | `string` | n/a | yes |
| <a name="input_vpn_link"></a> [vpn\_link](#input\_vpn\_link) | (Required) One or more vpn\_link blocks | <pre>list(object({<br/>    name                 = string<br/>    egress_nat_rule_ids  = optional(list(string))<br/>    ingress_nat_rule_ids = optional(list(string))<br/>    vpn_site_link_id     = string<br/>    bandwidth_mbps       = optional(number)<br/>    bgp_enabled          = optional(bool)<br/>    connection_mode      = optional(string)<br/>    ipsec_policy = optional(list(object({<br/>      dh_group                 = string<br/>      ike_encryption_algorithm = string<br/>      ike_integrity_algorithm  = string<br/>      encryption_algorithm     = string<br/>      integrity_algorithm      = string<br/>      pfs_group                = string<br/>      sa_data_size_kb          = number<br/>      sa_lifetime_sec          = number<br/>    })))<br/>    protocol                              = optional(string)<br/>    ratelimit_enabled                     = optional(bool)<br/>    route_weight                          = optional(number)<br/>    shared_key                            = optional(string)<br/>    local_azure_ip_address_enabled        = optional(bool)<br/>    policy_based_traffic_selector_enabled = optional(bool)<br/>    custom_bgp_address = optional(list(object({<br/>      ip_address          = string<br/>      ip_configuration_id = string<br/>    })))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
