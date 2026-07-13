# azure_vwan/routing

Opinionated Virtual WAN branch-routing module for FORGE/LIVE:

1. Creates an outbound hub route map that **Drops** routes whose AS-Path Contains the configured on-prem BGP ASN(s).
2. Attaches that map (plus default associate / none propagate) to existing VPN and ExpressRoute connections via `azapi_update_resource`.

Connection *resources* stay in their existing stacks. This module only owns route maps and connection `routingConfiguration`.

## Usage

```hcl
module "vwan_routing" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_vwan/routing?ref=<version>"

  providers = {
    azurerm = azurerm.connectivity
    azapi   = azapi
  }

  subscription_id_connectivity    = var.subscription_id_connectivity
  virtual_hub_id                  = data.azurerm_virtual_hub.this.id
  virtual_hub_resource_group_name = var.virtual_hub_resource_group_name
  onprem_bgp_asns                 = ["64551"]

  vpn_connection_routing = {
    kamloops = {
      vpn_gateway_name    = "..."
      vpn_connection_name = "..."
    }
  }

  express_route_connection_routing = {
    canadacentral = {
      express_route_gateway_name    = "..."
      express_route_connection_name = "..."
    }
  }
}
```

## Notes

- Removing `azapi_update_resource` from config does **not** clear Azure `routingConfiguration`.
- Pair with `azure_vpn/vpn_gateway_connection` `lifecycle.ignore_changes = [routing]` so VPN stacks do not fight this module.
- Low-level custom maps (without the ASN-drop opinion) remain available via `azure_vwan/route_maps`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.10 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.76 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.10 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_route_maps"></a> [route\_maps](#module\_route\_maps) | ../route_maps | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [azapi_update_resource.express_route_connection_routing](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azapi_update_resource.vpn_connection_routing](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_associated_route_table_id"></a> [associated\_route\_table\_id](#input\_associated\_route\_table\_id) | Hub route table ID to associate on branch connections. Defaults to the hub defaultRouteTable. | `string` | `null` | no |
| <a name="input_express_route_connection_routing"></a> [express\_route\_connection\_routing](#input\_express\_route\_connection\_routing) | ExpressRoute gateway connections that should receive the outbound route map via routingConfiguration. | <pre>map(object({<br/>    express_route_gateway_name    = string<br/>    express_route_connection_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_onprem_bgp_asns"></a> [onprem\_bgp\_asns](#input\_onprem\_bgp\_asns) | On-premises BGP ASNs to drop from outbound advertisements (AS-Path Contains). | `list(string)` | n/a | yes |
| <a name="input_outbound_route_map_key"></a> [outbound\_route\_map\_key](#input\_outbound\_route\_map\_key) | Stable Terraform map key for the outbound route map. | `string` | `"outbound_to_onprem"` | no |
| <a name="input_outbound_route_map_name"></a> [outbound\_route\_map\_name](#input\_outbound\_route\_map\_name) | Azure name of the outbound route map resource. | `string` | `"outbound-to-onprem"` | no |
| <a name="input_propagated_route_table_id"></a> [propagated\_route\_table\_id](#input\_propagated\_route\_table\_id) | Hub route table ID to propagate on branch connections. Defaults to the hub noneRouteTable. | `string` | `null` | no |
| <a name="input_propagated_route_table_labels"></a> [propagated\_route\_table\_labels](#input\_propagated\_route\_table\_labels) | Labels for propagatedRouteTables on branch connections. | `list(string)` | <pre>[<br/>  "none"<br/>]</pre> | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID for connectivity resources (used to build gateway parent IDs). | `string` | n/a | yes |
| <a name="input_virtual_hub_id"></a> [virtual\_hub\_id](#input\_virtual\_hub\_id) | Resource ID of the Virtual Hub. | `string` | n/a | yes |
| <a name="input_virtual_hub_resource_group_name"></a> [virtual\_hub\_resource\_group\_name](#input\_virtual\_hub\_resource\_group\_name) | Resource group name of the Virtual Hub / VPN / ExpressRoute gateways. | `string` | n/a | yes |
| <a name="input_vpn_connection_routing"></a> [vpn\_connection\_routing](#input\_vpn\_connection\_routing) | VPN gateway connections that should receive the outbound route map via routingConfiguration. | <pre>map(object({<br/>    vpn_gateway_name    = string<br/>    vpn_connection_name = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_express_route_connection_routing_ids"></a> [express\_route\_connection\_routing\_ids](#output\_express\_route\_connection\_routing\_ids) | ExpressRoute connections whose routingConfiguration is managed by this module. |
| <a name="output_outbound_route_map_id"></a> [outbound\_route\_map\_id](#output\_outbound\_route\_map\_id) | Resource ID of the outbound-to-onprem route map. |
| <a name="output_route_map_ids"></a> [route\_map\_ids](#output\_route\_map\_ids) | Map of route map keys to Azure resource IDs. |
| <a name="output_vpn_connection_routing_ids"></a> [vpn\_connection\_routing\_ids](#output\_vpn\_connection\_routing\_ids) | VPN connections whose routingConfiguration is managed by this module. |
<!-- END_TF_DOCS -->
