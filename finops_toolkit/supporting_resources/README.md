This directory is for supporting resources related to the FinOps Toolkit.

This includes:
- The IPAM CIDR reservation for the VNet
  - NOTE: The VNet is created as part for the FinOps Toolkit deployment itself
- Microsoft Fabric capacity
  - NOTE: This is used in connection with deploying the PowerBI Data Gateway and connecting it to the FinOps Hub

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azureipam"></a> [azureipam](#requirement\_azureipam) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_fabric"></a> [fabric](#requirement\_fabric) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azureipam"></a> [azureipam](#provider\_azureipam) | ~> 1.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_fabric"></a> [fabric](#provider\_fabric) | ~> 1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azureipam_reservation.finops_toolkit](https://registry.terraform.io/providers/XtratusCloud/azureipam/latest/docs/resources/reservation) | resource |
| [azurerm_fabric_capacity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/fabric_capacity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [fabric_capacity.example](https://registry.terraform.io/providers/microsoft/fabric/latest/docs/data-sources/capacity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IPAM_TOKEN"></a> [IPAM\_TOKEN](#input\_IPAM\_TOKEN) | (Required) The IPAM token to use for IP address management. | `string` | n/a | yes |
| <a name="input_administration_members"></a> [administration\_members](#input\_administration\_members) | (Optional) An array of administrator user identities. | `list(string)` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) This is either LIVE or FORGE. | `string` | n/a | yes |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | (Required) The name of the existing resource group in which to create the Fabric Capacity. | `string` | n/a | yes |
| <a name="input_fabric_capacity_name"></a> [fabric\_capacity\_name](#input\_fabric\_capacity\_name) | (Required) The name which should be used for the Fabric Capacity. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | (Required) The SKU of the Fabric Capacity. Possible values are F2, F4, F8, F16, F32, F64, F128, F256, F512, F1024, F2048. | <pre>object({<br/>    name = string<br/>    tier = string<br/>  })</pre> | <pre>{<br/>  "name": "F2",<br/>  "tier": "Fabric"<br/>}</pre> | no |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | (Required) Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to assign to the resource. Tags are a set of key/value pairs. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azureipam_reservation"></a> [azureipam\_reservation](#output\_azureipam\_reservation) | The IPAM reservation object |
| <a name="output_fabric_id"></a> [fabric\_id](#output\_fabric\_id) | The ID of the Fabric Capacity. |
| <a name="output_fabric_name"></a> [fabric\_name](#output\_fabric\_name) | The name of the Fabric Capacity. |
<!-- END_TF_DOCS -->
