# ADX Cluster for MDE Security Data

## Overview

The ADX Cluster is a specialized infrastructure component that enables limitless advanced hunting capabilities for MDE security data. It provides a powerful platform for security analysts to perform complex queries and analysis on large volumes of security telemetry data.

## Key Features

- **Unlimited Data Retention**: Store and analyze historical security data without time constraints
- **Advanced Querying**: Leverage Kusto Query Language (KQL) for sophisticated security analysis
- **Cost-Effective**: Optimized for security data ingestion and querying patterns
- **Scalable Architecture**: Built to handle growing security data volumes
- **Integration with MDE**: Seamless connection with Microsoft Defender for Endpoint

## Architecture

[Blog Series: Limitless Advanced Hunting with Azure Data Explorer (ADX)](https://techcommunity.microsoft.com/blog/microsoftthreatprotectionblog/blog-series-limitless-advanced-hunting-with-azure-data-explorer-adx/2328705)

The ADX cluster is designed with the following components:

1. **Data Ingestion Layer**

   - Handles streaming data from MDE
   - Optimized for high-throughput ingestion

2. **Storage Layer**

   - Hot cache for recent data
   - Cold storage for historical data
   - Optimized for security data patterns

3. **Query Layer**
   - High-performance query engine
   - Support for complex KQL queries
   - Built-in security analytics functions

## Benefits

- **Enhanced Security Analysis**: Perform deep historical analysis of security incidents
- **Cost Optimization**: Efficient storage and querying patterns
- **Improved Incident Response**: Quick access to historical security data
- **Advanced Hunting**: Support for complex security queries and patterns
- **Integration**: Seamless connection with Microsoft security stack

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 1.12.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 1.12.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.14.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.create_mapping_script](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.create_table_script](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_eventhub.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub) | resource |
| [azurerm_eventhub_consumer_group.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub_consumer_group) | resource |
| [azurerm_eventhub_namespace.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/eventhub_namespace) | resource |
| [azurerm_kusto_cluster.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_cluster) | resource |
| [azurerm_kusto_database.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_database) | resource |
| [azurerm_kusto_eventhub_data_connection.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/kusto_eventhub_data_connection) | resource |
| [azurerm_resource_group.adx](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.adx_eventhub_reader](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.adx_users](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/resources/role_assignment) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/4.14.0/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adx_capacity"></a> [adx\_capacity](#input\_adx\_capacity) | Capapcity for the ADX cluster | `number` | `2` | no |
| <a name="input_adx_cluster_name"></a> [adx\_cluster\_name](#input\_adx\_cluster\_name) | Name of the ADX cluster | `string` | `"adx-cluster"` | no |
| <a name="input_adx_data_connection_name"></a> [adx\_data\_connection\_name](#input\_adx\_data\_connection\_name) | Name of the data connection | `string` | `"adx-data-connection"` | no |
| <a name="input_adx_database_name"></a> [adx\_database\_name](#input\_adx\_database\_name) | Name of the ADX database | `string` | `"adx-database"` | no |
| <a name="input_adx_disk_encryption_enabled"></a> [adx\_disk\_encryption\_enabled](#input\_adx\_disk\_encryption\_enabled) | Specifies if the cluster's disk encryption is enabled | `bool` | `true` | no |
| <a name="input_adx_double_encryption_enabled"></a> [adx\_double\_encryption\_enabled](#input\_adx\_double\_encryption\_enabled) | Specifies if the double encryption is enabled | `bool` | `false` | no |
| <a name="input_adx_hot_cache_period"></a> [adx\_hot\_cache\_period](#input\_adx\_hot\_cache\_period) | The time period for which hot cache is enabled | `string` | `"P7D"` | no |
| <a name="input_adx_purge_enabled"></a> [adx\_purge\_enabled](#input\_adx\_purge\_enabled) | Specifies if the purge operations are enabled | `bool` | `false` | no |
| <a name="input_adx_sku"></a> [adx\_sku](#input\_adx\_sku) | SKU for the ADX cluster | `string` | `"Standard_D14_v2"` | no |
| <a name="input_adx_soft_delete_period"></a> [adx\_soft\_delete\_period](#input\_adx\_soft\_delete\_period) | The time period for which data should be kept before being soft deleted | `string` | `"P31D"` | no |
| <a name="input_adx_streaming_ingestion_enabled"></a> [adx\_streaming\_ingestion\_enabled](#input\_adx\_streaming\_ingestion\_enabled) | Specifies if the streaming ingest is enabled | `bool` | `true` | no |
| <a name="input_adx_table_settings"></a> [adx\_table\_settings](#input\_adx\_table\_settings) | Table settings for data connection | <pre>object({<br/>    table_name            = optional(string, "DefenderAdvancedHunting")<br/>    mapping_rule_name     = optional(string, "DefenderAdvancedHuntingMapping")<br/>    data_format           = optional(string, "MULTIJSON")<br/>    compression           = optional(string, "None")<br/>    database_routing_type = optional(string, "Multi")<br/>  })</pre> | <pre>{<br/>  "compression": "None",<br/>  "data_format": "MULTIJSON",<br/>  "database_routing_type": "Multi",<br/>  "mapping_rule_name": "DefenderAdvancedHuntingMapping",<br/>  "table_name": "DefenderAdvancedHunting"<br/>}</pre> | no |
| <a name="input_eventhub_auto_inflate_enabled"></a> [eventhub\_auto\_inflate\_enabled](#input\_eventhub\_auto\_inflate\_enabled) | Is Auto Inflate enabled for the EventHub Namespace? | `bool` | `false` | no |
| <a name="input_eventhub_capacity"></a> [eventhub\_capacity](#input\_eventhub\_capacity) | Specifies the Capacity / Throughput Units for a Standard SKU namespace | `number` | `1` | no |
| <a name="input_eventhub_capture_archive_name_format"></a> [eventhub\_capture\_archive\_name\_format](#input\_eventhub\_capture\_archive\_name\_format) | The naming convention used to name the archive | `string` | `"{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"` | no |
| <a name="input_eventhub_capture_container_name"></a> [eventhub\_capture\_container\_name](#input\_eventhub\_capture\_container\_name) | The name of the Container within the Storage Account where messages should be archived | `string` | `null` | no |
| <a name="input_eventhub_capture_encoding_format"></a> [eventhub\_capture\_encoding\_format](#input\_eventhub\_capture\_encoding\_format) | Specifies the encoding format for capture description | `string` | `"Avro"` | no |
| <a name="input_eventhub_capture_interval_in_seconds"></a> [eventhub\_capture\_interval\_in\_seconds](#input\_eventhub\_capture\_interval\_in\_seconds) | The time interval in seconds at which the capture will happen | `number` | `300` | no |
| <a name="input_eventhub_capture_size_limit_in_bytes"></a> [eventhub\_capture\_size\_limit\_in\_bytes](#input\_eventhub\_capture\_size\_limit\_in\_bytes) | The amount of data built up in your EventHub before a capture operation occurs | `number` | `314572800` | no |
| <a name="input_eventhub_capture_skip_empty_archives"></a> [eventhub\_capture\_skip\_empty\_archives](#input\_eventhub\_capture\_skip\_empty\_archives) | Indicates whether to skip empty archives or not | `bool` | `false` | no |
| <a name="input_eventhub_capture_storage_account_id"></a> [eventhub\_capture\_storage\_account\_id](#input\_eventhub\_capture\_storage\_account\_id) | The ID of the Storage Account where messages should be archived | `string` | `null` | no |
| <a name="input_eventhub_consumer_group_metadata"></a> [eventhub\_consumer\_group\_metadata](#input\_eventhub\_consumer\_group\_metadata) | Metadata for the consumer group | `string` | `null` | no |
| <a name="input_eventhub_consumer_group_name"></a> [eventhub\_consumer\_group\_name](#input\_eventhub\_consumer\_group\_name) | Name of the Event Hub Consumer group | `string` | `"adx-consumer-group"` | no |
| <a name="input_eventhub_enable_capture"></a> [eventhub\_enable\_capture](#input\_eventhub\_enable\_capture) | Enable capture for the Event Hub? | `bool` | `false` | no |
| <a name="input_eventhub_maximum_throughput_units"></a> [eventhub\_maximum\_throughput\_units](#input\_eventhub\_maximum\_throughput\_units) | Specifies the maximum number of throughput units when Auto Inflate is Enabled | `number` | `20` | no |
| <a name="input_eventhub_message_retention"></a> [eventhub\_message\_retention](#input\_eventhub\_message\_retention) | Message retention of the Event Hub | `number` | `1` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Name of the Event Hub | `string` | `"adx-eventhub"` | no |
| <a name="input_eventhub_namespace_name"></a> [eventhub\_namespace\_name](#input\_eventhub\_namespace\_name) | Name of the Event Hub namespace | `string` | `"adx-eventhub-namespace"` | no |
| <a name="input_eventhub_partition_count"></a> [eventhub\_partition\_count](#input\_eventhub\_partition\_count) | Partition count of the Event Hub | `number` | `1` | no |
| <a name="input_eventhub_sku"></a> [eventhub\_sku](#input\_eventhub\_sku) | SKU of the Event Hub | `string` | `"Standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | Location for the ADX resources | `string` | `"CanadaCentral"` | no |
| <a name="input_mde_authorized_users"></a> [mde\_authorized\_users](#input\_mde\_authorized\_users) | List of user principal names authorized to access Advanced Hunting data | `list(string)` | `[]` | no |
| <a name="input_mde_data_retention_days"></a> [mde\_data\_retention\_days](#input\_mde\_data\_retention\_days) | Number of days to retain Advanced Hunting data in ADX | `number` | `403` | no |
| <a name="input_mde_tenant_id"></a> [mde\_tenant\_id](#input\_mde\_tenant\_id) | Azure Active Directory tenant ID for Microsoft Defender for Endpoint integration | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name to deploy adx resources | `string` | `"adx-rg"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_advanced_hunting_endpoint"></a> [advanced\_hunting\_endpoint](#output\_advanced\_hunting\_endpoint) | Endpoint for Advanced Hunting queries |
| <a name="output_adx_cluster_id"></a> [adx\_cluster\_id](#output\_adx\_cluster\_id) | ADX cluster resource ID |
| <a name="output_adx_cluster_uri"></a> [adx\_cluster\_uri](#output\_adx\_cluster\_uri) | ADX cluster URL |
| <a name="output_adx_database_id"></a> [adx\_database\_id](#output\_adx\_database\_id) | ADX database resource ID |
| <a name="output_data_retention_period"></a> [data\_retention\_period](#output\_data\_retention\_period) | Configured data retention period in days |
| <a name="output_eventhub_id"></a> [eventhub\_id](#output\_eventhub\_id) | Event Hub resource ID |
| <a name="output_eventhub_namespace_id"></a> [eventhub\_namespace\_id](#output\_eventhub\_namespace\_id) | Event Hub Namespace resource ID |
<!-- END_TF_DOCS -->
