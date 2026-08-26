variable "location" {
  type        = string
  description = "The default location for resources in this management group. Used for policy managed identities."
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
  default     = ""
}

variable "subscription_id_identity" {
  type        = string
  description = "Subscription ID to use for \"identity\" resources."
  default     = ""
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = ""
}

variable "subscription_id_security" {
  type        = string
  description = "Subscription ID to use for \"security\" resources."
  default     = ""
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "A map of tags to apply to the resources created."
}
