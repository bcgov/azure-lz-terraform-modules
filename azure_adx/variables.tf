# Common variables (no prefix)
variable "resource_group_name" {
  description = "Resource group name to deploy adx resources"
  type        = string
}

variable "location" {
  description = "Location for the ADX resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ADX Cluster variables (keep adx_ prefix)
variable "adx_cluster_name" {
  description = "Name of the ADX cluster"
  type        = string
}

variable "adx_sku" {
  description = "SKU for the ADX cluster"
  type        = string
  default     = "Standard_D14_v2"
}

variable "adx_capacity" {
  description = "Capapcity for the ADX cluster"
  type        = number
  default     = 2
}

variable "adx_disk_encryption_enabled" {
  description = "Specifies if the cluster's disk encryption is enabled"
  type        = bool
  default     = true
}

variable "adx_streaming_ingestion_enabled" {
  description = "Specifies if the streaming ingest is enabled"
  type        = bool
  default     = true
}

variable "adx_purge_enabled" {
  description = "Specifies if the purge operations are enabled"
  type        = bool
  default     = false
}

variable "adx_double_encryption_enabled" {
  description = "Specifies if the double encryption is enabled"
  type        = bool
  default     = false
}

# ADX Database variables
variable "adx_database_name" {
  description = "Name of the ADX database"
  type        = string
}

variable "adx_hot_cache_period" {
  description = "The time period for which hot cache is enabled"
  type        = string
  default     = "P7D"
}

variable "adx_soft_delete_period" {
  description = "The time period for which data should be kept before being soft deleted"
  type        = string
  default     = "P31D"
}

# Event Hub Namespace variables
variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  type        = string
}

variable "eventhub_sku" {
  description = "SKU of the Event Hub"
  type        = string
  default     = "Standard"
}

variable "eventhub_capacity" {
  description = "Specifies the Capacity / Throughput Units for a Standard SKU namespace"
  type        = number
  default     = 1
}

variable "eventhub_auto_inflate_enabled" {
  description = "Is Auto Inflate enabled for the EventHub Namespace?"
  type        = bool
  default     = false
}

variable "eventhub_maximum_throughput_units" {
  description = "Specifies the maximum number of throughput units when Auto Inflate is Enabled"
  type        = number
  default     = 20
}

# Event Hub variables
variable "eventhub_name" {
  description = "Name of the Event Hub"
  type        = string
}

variable "eventhub_partition_count" {
  description = "Partition count of the Event Hub"
  type        = number
  default     = 1
}

variable "eventhub_message_retention" {
  description = "Message retention of the Event Hub"
  type        = number
  default     = 1
}

# Event Hub Consumer Group variables
variable "eventhub_consumer_group_name" {
  description = "Name of the Event Hub Consumer group"
  type        = string
  default     = "adx-consumer-group"
}

variable "eventhub_consumer_group_metadata" {
  description = "Metadata for the consumer group"
  type        = string
  default     = null
}

# Event Hub Capture variables
variable "eventhub_enable_capture" {
  description = "Enable capture for the Event Hub?"
  type        = bool
  default     = false
}

variable "eventhub_capture_encoding_format" {
  description = "Specifies the encoding format for capture description"
  type        = string
  default     = "Avro"
  validation {
    condition     = contains(["Avro", "AvroDeflate"], var.eventhub_capture_encoding_format)
    error_message = "Capture encoding format must be either Avro or AvroDeflate."
  }
}

variable "eventhub_capture_interval_in_seconds" {
  description = "The time interval in seconds at which the capture will happen"
  type        = number
  default     = 300
  validation {
    condition     = var.eventhub_capture_interval_in_seconds >= 60 && var.eventhub_capture_interval_in_seconds <= 900
    error_message = "Capture interval must be between 60 and 900 seconds."
  }
}

variable "eventhub_capture_size_limit_in_bytes" {
  description = "The amount of data built up in your EventHub before a capture operation occurs"
  type        = number
  default     = 314572800
  validation {
    condition     = var.eventhub_capture_size_limit_in_bytes >= 10485760 && var.eventhub_capture_size_limit_in_bytes <= 524288000
    error_message = "Capture size limit must be between 10485760 and 524288000 bytes."
  }
}

variable "eventhub_capture_skip_empty_archives" {
  description = "Indicates whether to skip empty archives or not"
  type        = bool
  default     = false
}

variable "eventhub_capture_archive_name_format" {
  description = "The naming convention used to name the archive"
  type        = string
  default     = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
  validation {
    condition     = can(regex("\\{Namespace\\}", var.eventhub_capture_archive_name_format)) && can(regex("\\{EventHub\\}", var.eventhub_capture_archive_name_format)) && can(regex("\\{PartitionId\\}", var.eventhub_capture_archive_name_format)) && can(regex("\\{Year\\}", var.eventhub_capture_archive_name_format)) && can(regex("\\{Month\\}", var.eventhub_capture_archive_name_format)) && can(regex("\\{Day\\}", var.eventhub_capture_archive_name_format))
    error_message = "Archive name format must contain at least {Namespace}, {EventHub}, {PartitionId}, {Year}, {Month}, and {Day}."
  }
}

variable "eventhub_capture_container_name" {
  description = "The name of the Container within the Storage Account where messages should be archived"
  type        = string
  default     = null
}

variable "eventhub_capture_storage_account_id" {
  description = "The ID of the Storage Account where messages should be archived"
  type        = string
  default     = null
}
# Data Connection variables
variable "adx_data_connection_name" {
  description = "Name of the data connection"
  type        = string
}

variable "adx_table_settings" {
  description = "Table settings for data connection"
  type = object({
    table_name            = optional(string)
    mapping_rule_name     = optional(string)
    data_format           = optional(string)
    compression           = optional(string)
    database_routing_type = optional(string)
  })
  default = null

  validation {
    condition = var.adx_table_settings == null ? true : (
      var.adx_table_settings.data_format == null ? true :
      contains([
        "avro", "csv", "json", "multiline", "psv", "raw", "scsv", "sohsv", "tsv", "txt",
        "AVRO", "CSV", "JSON", "MULTILINE", "PSV", "RAW", "SCSV", "SOHSV", "TSV", "TXT"
      ], var.adx_table_settings.data_format)
    )
    error_message = "Invalid data format. Must be one of: AVRO/avro, CSV/csv, JSON/json, MULTILINE/multiline, PSV/psv, RAW/raw, SCSV/scsv, SOHSV/sohsv, TSV/tsv, TXT/txt."
  }

  validation {
    condition = var.adx_table_settings == null ? true : (
      var.adx_table_settings.compression == null ? true :
      contains(["None", "GZip", "none", "gzip"], var.adx_table_settings.compression)
    )
    error_message = "Compression must be either None/none or GZip/gzip."
  }

  validation {
    condition = var.adx_table_settings == null ? true : (
      var.adx_table_settings.database_routing_type == null ? true :
      contains(["Single", "Multi", "single", "multi"], var.adx_table_settings.database_routing_type)
    )
    error_message = "Database routing type must be either Single/single or Multi/multi."
  }
}

