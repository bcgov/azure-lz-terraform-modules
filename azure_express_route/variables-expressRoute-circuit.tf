variable "express_route_circuit_name" {
  description = "(Required) The name of the ExpressRoute circuit."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the ExpressRoute circuit."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists."
  type        = string
}

variable "sku" {
  description = "(Required) A sku block for the ExpressRoute circuit"
  type = object({
    tier   = string
    family = string
  })

  validation {
    condition     = contains(["Basic", "Local", "Standard", "Premium"], var.sku.tier)
    error_message = "The sku tier must be either Basic, Local, Standard or Premium."
  }

  validation {
    condition     = contains(["MeteredData", "UnlimitedData"], var.sku.family)
    error_message = "The sku family must be either MeteredData or UnlimitedData."
  }
}

variable "service_provider_name" {
  description = "(Optional) The name of the ExpressRoute Service Provider."
  type        = string
  default     = null
}

variable "peering_location" {
  description = "(Optional) The name of the peering location and not the Azure resource location."
  type        = string
  default     = null
}

variable "bandwidth_in_mbps" {
  description = "(Optional) The bandwidth in Mbps of the circuit being created on the Service Provider."
  type        = number
  default     = null
}

variable "allow_classic_operations" {
  description = "(Optional) Allow the circuit to interact with classic (RDFE) resources."
  type        = bool
  default     = false
}

variable "authorization_key" {
  description = "(Optional) The authorization key. This can be used to set up an ExpressRoute Circuit with an ExpressRoute Port from another subscription."
  type        = string
  default     = null
}