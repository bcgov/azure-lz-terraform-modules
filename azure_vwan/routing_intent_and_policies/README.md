# Azure Virtual WAN Routing Intent and Policies

This Terraform code is designed to manage the routing policies for vWAN. This is speficically for the Private Address Prefixes, which is linked to the Default route table.

## Of Note

We originally attempted to include calling the `vwan_routing_intent_and_policies` module as part of the CAF deployment, but Terraform threw the following error:

```shell
--------------------------------------------------------------------------------
RESPONSE 400: 400 Bad Request │ ERROR CODE: CannotModifyRoutingPolicyInternalRoutes
--------------------------------------------------------------------------------
{
  "error": {
    "code": "CannotModifyRoutingPolicyInternalRoutes",
    "message": "Cannot add, update or delete route /subscriptions/09bd024b-fbda-417d-b8db-694680c2b44e/resourceGroups/bcgov-managed-lz-forge-connectivity/providers/Microsoft.Network/virtualHubs/bcgov-managed-lz-forge-hub-canadacentral/hubRouteTables/defaultRouteTable created by Routing Intent.",
    "details": []
  }
}
```

According to CoPilot, this is because "_the `defaultRouteTable` routes when routing intent is enabled are **owned by routing intent** and are read-only._"

However, when calling the module directly, we can successfully update the routing intent and policies, which correctly updates the Private Address Prefixes in the Default Route Table.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0, != 1.13.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0, != 1.13.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_update_resource.vwan_routing_intent_and_policies](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_firewall_resource_id"></a> [firewall\_resource\_id](#input\_firewall\_resource\_id) | Resource ID of the Azure Firewall. | `string` | n/a | yes |
| <a name="input_onpremises_address_ranges"></a> [onpremises\_address\_ranges](#input\_onpremises\_address\_ranges) | List of on-premises address ranges. | `list(string)` | n/a | yes |
| <a name="input_rfc_1918_address_ranges"></a> [rfc\_1918\_address\_ranges](#input\_rfc\_1918\_address\_ranges) | List of RFC 1918 address ranges. | `list(string)` | <pre>[<br/>  "10.0.0.0/8",<br/>  "172.16.0.0/12",<br/>  "192.168.0.0/16",<br/>  "100.64.0.0/10"<br/>]</pre> | no |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_vhub_resource_id"></a> [vhub\_resource\_id](#input\_vhub\_resource\_id) | Resource ID of the Virtual Hub. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_routing_intent_and_policies_routes"></a> [routing\_intent\_and\_policies\_routes](#output\_routing\_intent\_and\_policies\_routes) | n/a |
<!-- END_TF_DOCS -->
