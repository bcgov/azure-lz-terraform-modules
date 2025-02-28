variable "collector_policy_name" {
  description = "(Required) Specifies the name which should be used for this Network Function Collector Policy."
  type        = string  
}

# variable "traffic_collector_id" {
#   description = "(Required) Specifies the Azure Traffic Collector ID of the Network Function Collector Policy."
#   type        = string  
# }

variable "ipfx_emission_destination_types" {
  description = "(Required) A list of emission destination types. The only possible value is AzureMonitor."
  type        = list(string)
  default = ["AzureMonitor"]
}

variable "ipfx_ingestion_source_resource_ids" {
  description = "(Required) A list of ingestion source resource IDs."
  type        = list(string) 
}
