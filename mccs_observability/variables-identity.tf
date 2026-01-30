#------------------------------------------------------------------------------
# Identity and RBAC Variables
#------------------------------------------------------------------------------

variable "cloud_team_group_id" {
  type        = string
  description = "The Object ID of the Entra ID group for the Cloud Team (Grafana Admin, Key Vault Secrets Officer)."
}

variable "noc_team_group_id" {
  type        = string
  description = "The Object ID of the Entra ID group for the NOC Team (Grafana Editor)."
  default     = null
}

variable "service_desk_group_id" {
  type        = string
  description = "The Object ID of the Entra ID group for Service Desk (Grafana Viewer)."
  default     = null
}

variable "terraform_spn_object_id" {
  type        = string
  description = "The Object ID of the Terraform Service Principal for Key Vault access."
  default     = null
}
