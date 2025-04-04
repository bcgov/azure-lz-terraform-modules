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
| <a name="requirement_azureipam"></a> [azureipam](#requirement\_azureipam) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azureipam"></a> [azureipam](#provider\_azureipam) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azureipam_reservation.finops_toolkit](https://registry.terraform.io/providers/XtratusCloud/azureipam/latest/docs/resources/reservation) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IPAM_TOKEN"></a> [IPAM\_TOKEN](#input\_IPAM\_TOKEN) | (Required) The IPAM token to use for IP address management. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) This is either LIVE or FORGE. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management) | (Required) Subscription ID to use for "management" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to assign to the resource. Tags are a set of key/value pairs. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azureipam_reservation"></a> [azureipam\_reservation](#output\_azureipam\_reservation) | The IPAM reservation object |
<!-- END_TF_DOCS -->
