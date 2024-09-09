variable "express_route_gateway_resource_group_name" {
  description = "(Required) The name of the Resource Group where the Express Route Gateway is located."
  type        = string
}

variable "express_route_circuit_resource_group_name" {
  description = "(Required) The name of the Resource Group where the Express Route circuit is located."
  type        = string
}

variable "express_route_circuit_name" {
  description = "(Required) The name of the Express Route Circuit that this Express Route Connection connects with."
  type        = string
}

variable "express_route_gateway_name" {
  description = "(Required) The name of the Express Route Gateway that this Express Route Connection connects with."
  type        = string
}

variable "circuit_peering_type" {
  description = "(Required) The type of the Express Route Circuit Peering."
  type        = string
}

variable "express_route_connection_name" {
  description = "(Required) The name which should be used for this Express Route Connection."
  type        = string
}

variable "authorization_key" {
  description = "(Optional) The authorization key to establish the Express Route Connection."
  type        = string
  default     = null
}

variable "enable_internet_security" {
  description = "(Optional) Is Internet security enabled for this Express Route Connection?"
  type        = bool
  default     = null
}

variable "express_route_gateway_bypass_enabled" {
  description = "(Optional) Specified whether Fast Path is enabled for Virtual Wan Firewall Hub."
  type        = bool
  default     = false
}

variable "private_link_fast_path_enabled" {
  description = "(Optional) Bypass the Express Route gateway when accessing private-links. When enabled express_route_gateway_bypass_enabled must be set to true."
  type        = bool
  default     = false

  validation {
    condition = (
      (var.express_route_gateway_bypass_enabled == true &&
      var.private_link_fast_path_enabled == true) ||
      (var.express_route_gateway_bypass_enabled == false &&
      var.private_link_fast_path_enabled == false)
    )
    error_message = "private_link_fast_path_enabled must be set to true when express_route_gateway_bypass_enabled is set to true."
  }
}

variable "routing" {
  description = "(Optional) A routing block as defined below."
  type = object({
    associated_route_table_id = optional(string)
    inbound_route_map_id      = optional(string)
    outbound_route_map_id     = optional(string)
    propagated_route_table = optional(object({
      labels          = optional(list(string))
      route_table_ids = optional(list(string))
    }))
  })
  default = null
}

variable "routing_weight" {
  description = "(Optional) The routing weight associated to the Express Route Connection."
  type        = number
  default     = 0

  validation {
    condition     = var.routing_weight >= 0 && var.routing_weight <= 32000
    error_message = "routing_weight must be between 0 and 32000."
  }
}
