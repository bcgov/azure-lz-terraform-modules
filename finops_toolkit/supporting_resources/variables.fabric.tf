variable "fabric_capacity_name" {
  description = "(Required) The name which should be used for the Fabric Capacity."
  type        = string

  # Name must be lowercase and can only contain letters, numbers, no hyphens, and underscores.
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.fabric_capacity_name))
    error_message = "The Fabric Capacity name must be lowercase and can only contain letters, numbers, no hyphens, and underscores."
  }
}

variable "existing_resource_group_name" {
  description = "(Required) The name of the existing resource group in which to create the Fabric Capacity."
  type        = string
}

variable "sku" {
  description = "(Required) The SKU of the Fabric Capacity. Possible values are F2, F4, F8, F16, F32, F64, F128, F256, F512, F1024, F2048."
  type = object({
    name = string
    tier = string
  })
  default = {
    name = "F2"
    tier = "Fabric"
  }

  validation {
    condition     = contains(["F2", "F4", "F8", "F16", "F32", "F64", "F128", "F256", "F512", "F1024", "F2048"], var.sku.name)
    error_message = "The SKU name must be one of the following: F2, F4, F8, F16, F32, F64, F128, F256, F512, F1024, F2048."
  }
  validation {
    condition     = var.sku.tier == "Fabric"
    error_message = "The SKU tier must be 'Fabric'."
  }
}

variable "administration_members" {
  description = "(Optional) An array of administrator user identities."
  type        = list(string)
  default     = null
}
