variable "express_route_circuit" {
  description = "Express Route circuit configuration"
  type = list(object({
    express_route_circuit_name = string
    location                   = string
    sku = object({
      tier   = string
      family = string
    })
    service_provider_name    = optional(string, null)
    peering_location         = optional(string, null)
    bandwidth_in_mbps        = optional(number, null)
    allow_classic_operations = optional(bool, false)
    express_route_port_id    = optional(string, null)
    bandwidth_in_gbps        = optional(number, null)
    authorization_key        = optional(string, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for circuit in var.express_route_circuit : contains(["Basic", "Local", "Standard", "Premium"], circuit.sku.tier)
    ])
    error_message = "The sku tier must be either Basic, Local, Standard or Premium."
  }

  validation {
    condition = alltrue([
      for circuit in var.express_route_circuit : contains(["MeteredData", "UnlimitedData"], circuit.sku.family)
    ])
    error_message = "The sku family must be either MeteredData or UnlimitedData."
  }
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the ExpressRoute circuit."
  type        = string
}

variable "resource_group_location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
  type        = string
}
