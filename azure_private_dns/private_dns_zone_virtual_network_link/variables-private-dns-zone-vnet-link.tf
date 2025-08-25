variable "private_dns_zone_virtual_network_link" {
  type = map(object({
    private_dns_zone_vnet_link_name = string
    private_dns_zone_name           = string
    resource_group_name             = string
    virtual_network_id              = string
    registration_enabled            = optional(bool, false)
    tags                            = optional(map(string), {})
  }))
}

# variable "private_dns_zone_vnet_link_name" {
#   description = "(Required) The name of the Private DNS Zone Virtual Network Link."
#   type        = string
# }

# variable "private_dns_zone_name" {
#   description = "(Required) The name of the Private DNS zone (without a terminating dot)."
#   type        = string
# }

# variable "resource_group_name" {
#   description = "(Required) Specifies the resource group where the Private DNS Zone exists."
#   type        = string
# }

# variable "virtual_network_id" {
#   description = "(Required) The ID of the Virtual Network that should be linked to the DNS Zone."
#   type        = string
# }

# variable "registration_enabled" {
#   description = "(Optional) Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled?"
#   type        = bool
#   default     = false
# }

# variable "resolution_policy" {
#   description = "(Optional) Specifies the resolution policy of the Private DNS Zone Virtual Network Link."
#   type        = string
#   default     = "Default"

#   validation {
#     condition     = contains(["Default", "NxDomainRedirect"], var.resolution_policy)
#     error_message = "The resolution_policy must be either 'Default' or 'NxDomainRedirect'."
#   }
# }

# variable "tags" {
#   description = "(Optional) A mapping of tags to assign to the resource."
#   type        = map(string)
#   default     = {}
# }
