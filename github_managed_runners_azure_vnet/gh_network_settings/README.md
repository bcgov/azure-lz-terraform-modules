# gh_network_settings

IMPORTANT: This module is created to be used in a centralized deployment within the Connectivity subscription. It has not been coded in a reusable way for other subscriptions.

If, in the future, this module needs to be used in other Landing Zone subscriptions, certain assumptions would be made, including:

- The target Virtual Network (VNet) already exists, and therefore no new IPAM reservations are needed
- The VNet is already connected to the Virtual WAN Hub, and therefore no new Virtual Hub connections are needed
- VNet flow logs are already configured
- A Network Security Group (NSG) already exists and is associated with the target subnet (though additional rules will be required)
- The target subnet already exists and is delegated to Microsoft.GitHub/hostedRunners

Modification of this module would be required to support these assumptions, and the module would need to be refactored to support a more generic use case.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.github_hosted_runners_network_settings](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_hosted_runners_resource_group_id"></a> [github\_hosted\_runners\_resource\_group\_id](#input\_github\_hosted\_runners\_resource\_group\_id) | The Resource Group ID where the GitHub runners will be deployed | `string` | n/a | yes |
| <a name="input_github_hosted_runners_subnet_id"></a> [github\_hosted\_runners\_subnet\_id](#input\_github\_hosted\_runners\_subnet\_id) | The subnet ID where the GitHub runners will be deployed | `string` | n/a | yes |
| <a name="input_github_organization_id"></a> [github\_organization\_id](#input\_github\_organization\_id) | (Required) The GitHub business (enterprise/organization) ID associated to the Azure subscription | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_network_settings_name"></a> [network\_settings\_name](#input\_network\_settings\_name) | The name of the GitHub Network Settings resource | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to the resources | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_hosted_runners_network_settings"></a> [github\_hosted\_runners\_network\_settings](#output\_github\_hosted\_runners\_network\_settings) | The GitHub network settings resource |
<!-- END_TF_DOCS -->
