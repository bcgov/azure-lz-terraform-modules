# Use variables to customize the deployment

variable "root_parent_id" {
  type        = string
  description = "Sets the value for the parent management group."
}

variable "root_id" {
  type        = string
  description = "Sets the value used for generating unique resource naming within the module."
}

variable "root_name" {
  type        = string
  description = "Sets the value used for the \"intermediate root\" management group display name."
}

variable "primary_location" {
  type        = string
  description = "Sets the location for \"primary\" resources to be created in."
}

variable "secondary_location" {
  type        = string
  description = "Sets the location for \"secondary\" resources to be created in."
}

variable "country_location" {
  type        = string
  description = "Sets the country location. Used by some Azure resources taht are not tied to the regions."
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
}

variable "subscription_id_identity" {
  type        = string
  description = "Subscription ID to use for \"identity\" resources."
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
}

variable "configure_connectivity_resources" {
  type        = any
  description = "Configuration settings for \"connectivity\" resources."
}

variable "configure_management_resources" {
  type        = any
  description = "Configuration settings for \"management\" resources."
}

# NOTE: This variable was created to allow for setting Policies to "audit" in LIVE, when the default effect is "deny"
# to allow for testing and validation of the policies before enforcing them.
variable "policy_effect" {
  type        = string
  description = "Sets the effect for the policy assignment."
  default     = null
}

variable "VNet-DNS-Settings" {
  type        = list(any)
  description = "Sets the VNet DNS settings for the policy assignment."
}

variable "enforce_aks_cidrs_parameters" {
  type = object({
    allowedPodCidrRanges     = list(string)
    enforceServiceCidr       = bool
    allowedServiceCidrRanges = list(string)
    effect                   = string
  })
  description = "Parameter values for the Enforce-AKS-CIDRs policy assignment."
}

variable "aks_security_best_prac_parameters" {
  type = object({
    enforce_azure_cni_overlay    = string
    enforce_entra_id_integration = string
    enforce_kubernetes_rbac      = string
    enforce_azure_rbac           = string
    enforce_disable_local_auth   = string
    enforce_workload_identity    = string
    enforce_managed_identity     = string
    enforce_oidc_issuer          = string
    enforce_secrets_store_csi    = string
    enforce_acns_security        = string
    enforce_cilium_dataplane     = string
    audit_azure_policy_addon     = string
    deploy_azure_policy_addon    = string
    deploy_image_cleaner         = string
    audit_image_cleaner          = string
  })
  description = "Parameter values for the AKS-Security-BestPrac initiative assignment."
}

variable "enforce_private_cluster" {
  type = object({
    effect = string
  })
  description = "Parameter value for the Enforce-AKS-Private-Cluster policy assignment."
}

variable "network_watcher_storage_account_resource_group" {
  type        = string
  description = "The Resource Group of the Storage Account used for Network Watcher VNet Flow Logs."
}

variable "network_watcher_storage_account_name" {
  type        = string
  description = "The Storage Account name used for Network Watcher VNet Flow Logs."
}

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

variable "sqlmi_disable_public_endpoint_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the SQLMI-Disable-PublicData policy assignment."
}

variable "sqlmi_entra_authentication_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the SQLMI-Entra-AuthN policy assignment."
}
