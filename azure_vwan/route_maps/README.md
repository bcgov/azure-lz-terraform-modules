# azure_vwan/route_maps

Manages Azure Virtual WAN hub route maps (`azurerm_route_map`).

Use this to control routes advertised to or from VPN and ExpressRoute connections (for example, drop on-premises ASNs outbound, or summarize Azure prefixes).

Attachment to connections is **not** handled here. Pass the output route map ID into:

- `azure_vpn/vpn_gateway_connection` → `routing.outbound_route_map_id` / `inbound_route_map_id`
- `azure_express_route/express_route_connection` → `routing.outbound_route_map_id` / `inbound_route_map_id`

## Example

```hcl
module "vwan_route_maps" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_vwan/route_maps?ref=vX.Y.Z"

  subscription_id_connectivity = var.subscription_id_connectivity
  virtual_hub_id               = data.azurerm_virtual_hub.this.id

  route_maps = {
    outbound_to_onprem = {
      name = "outbound-to-onprem"
      rules = [
        {
          name                 = "drop-onprem-asn"
          next_step_if_matched = "Terminate"
          match_criteria = [
            {
              match_condition = "Contains"
              as_path         = ["64551"]
            }
          ]
          actions = [
            {
              type = "Drop"
            }
          ]
        }
      ]
    }
  }
}
```

## Import

```shell
terraform import 'module.vwan_route_maps.azurerm_route_map.this["outbound_to_onprem"]' \
  /subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/virtualHubs/<hub>/routeMaps/outbound-to-onprem
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.76 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.76 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_route_map.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_route_maps"></a> [route\_maps](#input\_route\_maps) | Map of Virtual Hub route maps to manage.<br/>Key is a stable Terraform identifier; each value.name is the Azure route map name.<br/>Rules are applied in list order. | <pre>map(object({<br/>    name = string<br/>    rules = list(object({<br/>      name                 = string<br/>      next_step_if_matched = optional(string, "Terminate")<br/>      match_criteria = optional(list(object({<br/>        match_condition = string<br/>        as_path         = optional(list(string), [])<br/>        community       = optional(list(string), [])<br/>        route_prefix    = optional(list(string), [])<br/>      })), [])<br/>      actions = optional(list(object({<br/>        type         = string<br/>        as_path      = optional(list(string), [])<br/>        community    = optional(list(string), [])<br/>        route_prefix = optional(list(string), [])<br/>      })), [])<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_virtual_hub_id"></a> [virtual\_hub\_id](#input\_virtual\_hub\_id) | Resource ID of the Virtual Hub that owns the route maps. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_route_map_ids"></a> [route\_map\_ids](#output\_route\_map\_ids) | Map of route map Terraform keys to Azure resource IDs. |
| <a name="output_route_maps"></a> [route\_maps](#output\_route\_maps) | Full azurerm\_route\_map resources keyed by Terraform map key. |
<!-- END_TF_DOCS -->
