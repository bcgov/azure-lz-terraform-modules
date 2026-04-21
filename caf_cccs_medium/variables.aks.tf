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