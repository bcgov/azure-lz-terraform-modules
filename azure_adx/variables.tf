variable "resource_group_name" {
  description = "Resource group name to deploy adx resources"
  type        = string
}
variable "location" {
  description = "Location for the ADX resources"
  type        = string
}
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

# variable "mtp_workspace_name" {
#   description = "Name of the Microsoft Threat Protection workspace"
#   type        = string
# }

variable "data_connection_name" {
  description = "Name of the data connection"
  type        = string
}
variable "event_hub_namespace_name" {
  description = "Name of the Event Hub namespace"
  type        = string
}
variable "event_hub_name" {
  description = "Name of the Event Hub"
  type        = string
}
variable "event_hub_sku" {
  description = "SKU of the Event Hub"
  type        = string
  default     = "Standard"
}
variable "event_hub_partition_count" {
  description = "Partition count of the Event Hub"
  type        = number
  default     = 1
}
variable "event_hub_message_retention" {
  description = "Message retention of the Event Hub"
  type        = number
  default     = 1
}
variable "event_hub_consumer_group_name" {
  description = "Name of the Event Hub Consumer group"
  type        = string
  default     = "adx-consumer-group"
}
