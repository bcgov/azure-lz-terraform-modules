# Use variables to customize the deployment

variable "root_parent_id" {
  type        = string
  description = "Sets the value for the parent management group."
}

variable "root_id" {
  type        = string
  description = "Sets the value used for generating unique resource naming within the module."
}

variable "primary_location" {
  type        = string
  description = "Sets the location for \"primary\" resources to be created in."
}

variable "secondary_location" {
  type        = string
  description = "Sets the location for \"secondary\" resources to be created in."
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "enable_ddos_protection" {
  type        = bool
  description = "Controls whether to create a DDoS Network Protection plan and link to hub virtual networks."
}

variable "connectivity_resources_tags" {
  type        = map(string)
  description = "Specify tags to add to \"connectivity\" resources."
}

variable "firewall_child_policy_id" {
  type        = string
  description = "Sets the value for the Firewall firewall_policy_id."
}

variable "vwan_hub_address_prefix" {
  type        = string
  description = "Sets the address prefix for the vWAN hub."
}

variable "private_dns_resolution_policy" {
  description = <<-EOT
    Resolution policy for Private DNS Zone Virtual Network Links.
    - 'Default': Standard private DNS resolution only
    - 'NxDomainRedirect': Enables fallback to public DNS resolution when private DNS returns NXDOMAIN

    Per Microsoft documentation, this is only applicable for privatelink zones and A/AAAA/CNAME queries.
    When set to NxDomainRedirect, Azure DNS resolver falls back to public resolution if private DNS
    query resolution results in non-existent domain response.
  EOT
  type        = string
  default     = "NxDomainRedirect"

  validation {
    condition     = contains(["Default", "NxDomainRedirect"], var.private_dns_resolution_policy)
    error_message = "Resolution policy must be either 'Default' or 'NxDomainRedirect'."
  }
}
