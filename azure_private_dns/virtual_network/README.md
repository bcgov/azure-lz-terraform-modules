# virtual_network

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azureipam"></a> [azureipam](#requirement\_azureipam) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azureipam"></a> [azureipam](#provider\_azureipam) | ~> 1.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azureipam_reservation.private_dns_resolver](https://registry.terraform.io/providers/XtratusCloud/azureipam/latest/docs/resources/reservation) | resource |
| [azurerm_network_security_group.inbound_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.outbound_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_virtual_hub_connection.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_virtual_hub.vwan_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_hub) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_IPAM_TOKEN"></a> [IPAM\_TOKEN](#input\_IPAM\_TOKEN) | (Required) The IPAM token to use for IP address management. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | (Required) This is either LIVE or FORGE. | `string` | n/a | yes |
| <a name="input_firewall_private_ip_address"></a> [firewall\_private\_ip\_address](#input\_firewall\_private\_ip\_address) | (Required) Private IP address of the Azure Firewall to connect to. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_private_dns_resolver_virtual_network_name"></a> [private\_dns\_resolver\_virtual\_network\_name](#input\_private\_dns\_resolver\_virtual\_network\_name) | (Required) Name of the Virtual Network to deploy the Private DNS Resolver into. | `string` | n/a | yes |
| <a name="input_private_dns_resource_group_name"></a> [private\_dns\_resource\_group\_name](#input\_private\_dns\_resource\_group\_name) | (Required) Name of the Resource Group to deploy the Private DNS Resolver into. | `string` | n/a | yes |
| <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity) | (Required) Subscription ID to use for "connectivity" resources. | `string` | n/a | yes |
| <a name="input_virtual_wan_hub_name"></a> [virtual\_wan\_hub\_name](#input\_virtual\_wan\_hub\_name) | (Required) Name of the Virtual WAN Hub to connect to. | `string` | n/a | yes |
| <a name="input_virtual_wan_hub_resource_group"></a> [virtual\_wan\_hub\_resource\_group](#input\_virtual\_wan\_hub\_resource\_group) | (Required) Resource Group of the Virtual WAN hub. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_resolver_cidr"></a> [private\_dns\_resolver\_cidr](#output\_private\_dns\_resolver\_cidr) | The CIDR block of the Private DNS Resolver |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The Private DNS Resolver resource group name |
| <a name="output_virtual_hub_connection"></a> [virtual\_hub\_connection](#output\_virtual\_hub\_connection) | The Private DNS Resolver virtual hub connection object |
| <a name="output_virtual_network"></a> [virtual\_network](#output\_virtual\_network) | The Private DNS Resolver virtual network object |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The Private DNS Resolver virtual network ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
