## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub_namespace) | resource |
| [azurerm_kusto_cluster.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_cluster) | resource |
| [azurerm_kusto_database.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_database) | resource |
| [azurerm_kusto_eventhub_data_connection.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_eventhub_data_connection) | resource |
| [azurerm_resource_group.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adx_capacity"></a> [adx\_capacity](#input\_adx\_capacity) | Capapcity for the ADX cluster | `number` | `2` | no |
| <a name="input_adx_cluster_name"></a> [adx\_cluster\_name](#input\_adx\_cluster\_name) | Name of the ADX cluster | `string` | n/a | yes |
| <a name="input_adx_sku"></a> [adx\_sku](#input\_adx\_sku) | SKU for the ADX cluster | `string` | `"Standard_D14_v2"` | no |
| <a name="input_data_connection_name"></a> [data\_connection\_name](#input\_data\_connection\_name) | Name of the data connection | `string` | n/a | yes |
| <a name="input_event_hub_consumer_group_name"></a> [event\_hub\_consumer\_group\_name](#input\_event\_hub\_consumer\_group\_name) | Name of the Event Hub Consumer group | `string` | `"adx-consumer-group"` | no |
| <a name="input_event_hub_message_retention"></a> [event\_hub\_message\_retention](#input\_event\_hub\_message\_retention) | Message retention of the Event Hub | `number` | `1` | no |
| <a name="input_event_hub_name"></a> [event\_hub\_name](#input\_event\_hub\_name) | Name of the Event Hub | `string` | n/a | yes |
| <a name="input_event_hub_namespace_name"></a> [event\_hub\_namespace\_name](#input\_event\_hub\_namespace\_name) | Name of the Event Hub namespace | `string` | n/a | yes |
| <a name="input_event_hub_partition_count"></a> [event\_hub\_partition\_count](#input\_event\_hub\_partition\_count) | Partition count of the Event Hub | `number` | `1` | no |
| <a name="input_event_hub_sku"></a> [event\_hub\_sku](#input\_event\_hub\_sku) | SKU of the Event Hub | `string` | `"Standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location for the ADX resources | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name to deploy adx resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adx_cluster_uri"></a> [adx\_cluster\_uri](#output\_adx\_cluster\_uri) | ADX cluster URL |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_eventhub.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub_namespace) | resource |
| [azurerm_kusto_cluster.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_cluster) | resource |
| [azurerm_kusto_database.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_database) | resource |
| [azurerm_kusto_eventhub_data_connection.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_eventhub_data_connection) | resource |
| [azurerm_resource_group.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adx_capacity"></a> [adx\_capacity](#input\_adx\_capacity) | Capapcity for the ADX cluster | `number` | `2` | no |
| <a name="input_adx_cluster_name"></a> [adx\_cluster\_name](#input\_adx\_cluster\_name) | Name of the ADX cluster | `string` | n/a | yes |
| <a name="input_adx_sku"></a> [adx\_sku](#input\_adx\_sku) | SKU for the ADX cluster | `string` | `"Standard_D14_v2"` | no |
| <a name="input_data_connection_name"></a> [data\_connection\_name](#input\_data\_connection\_name) | Name of the data connection | `string` | n/a | yes |
| <a name="input_event_hub_consumer_group_name"></a> [event\_hub\_consumer\_group\_name](#input\_event\_hub\_consumer\_group\_name) | Name of the Event Hub Consumer group | `string` | `"adx-consumer-group"` | no |
| <a name="input_event_hub_message_retention"></a> [event\_hub\_message\_retention](#input\_event\_hub\_message\_retention) | Message retention of the Event Hub | `number` | `1` | no |
| <a name="input_event_hub_name"></a> [event\_hub\_name](#input\_event\_hub\_name) | Name of the Event Hub | `string` | n/a | yes |
| <a name="input_event_hub_namespace_name"></a> [event\_hub\_namespace\_name](#input\_event\_hub\_namespace\_name) | Name of the Event Hub namespace | `string` | n/a | yes |
| <a name="input_event_hub_partition_count"></a> [event\_hub\_partition\_count](#input\_event\_hub\_partition\_count) | Partition count of the Event Hub | `number` | `1` | no |
| <a name="input_event_hub_sku"></a> [event\_hub\_sku](#input\_event\_hub\_sku) | SKU of the Event Hub | `string` | `"Standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location for the ADX resources | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name to deploy adx resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_adx_cluster_uri"></a> [adx\_cluster\_uri](#output\_adx\_cluster\_uri) | ADX cluster URL |
<!-- END_TF_DOCS -->