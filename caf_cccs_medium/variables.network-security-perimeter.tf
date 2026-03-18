variable "nsp_name" {
  type        = string
  description = "Name of the Network Security Perimeter (NSP) to associate resources with."
  default     = ""
}

variable "nsp_resource_group_name" {
  type        = string
  description = "Resource group name where the Network Security Perimeter (NSP) exists."
  default     = ""
}

variable "nsp_subscription_id" {
  type        = string
  description = "Subscription ID where the Network Security Perimeter (NSP) exists."
  default     = ""
}

variable "nsp_profile" {
  type        = string
  description = "Name of the NSP profile."
  default     = ""
}
