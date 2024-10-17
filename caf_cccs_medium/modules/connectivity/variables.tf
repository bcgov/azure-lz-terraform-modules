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

# variable "firewall_baseline_policy_id" {
#   type        = string
#   description = "Sets the value for the Firewall base_policy_id."
# }

variable "firewall_child_policy_id" {
  type        = string
  description = "Sets the value for the Firewall firewall_policy_id."
}

variable "vwan_hub_address_prefix" {
  type        = string
  description = "Sets the address prefix for the vWAN hub."
}
