variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = ""
}

variable "location" {
  description = "(Required) The Azure Region where the Network Manager IPAM Pool should exist. Changing this forces a new Network Manager IPAM Pool to be created."
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags which should be assigned to the Network Manager IPAM Pool."
  type        = map(string)
  default     = {}
}
