variable "architecture_name" {
  type        = string
  description = "ALZ architecture definition name in ./lib."
  default     = "var_alz_custom"
}

variable "parent_resource_id" {
  type        = string
  description = "Parent management group name. Leave empty to target tenant root group."
  default     = ""

  validation {
    condition     = var.parent_resource_id == "" || !strcontains(var.parent_resource_id, "/")
    error_message = "parent_resource_id must be a management group name (no slashes)."
  }
}


# variable "subscription_placement" {
#   type = map(object({
#     subscription_id       = string
#     management_group_name = string
#   }))

#   description = "A map of subscription placements for the architecture. Each key is a workload name, and the value is an object containing the subscription ID and management group name."
# }

variable "subscription_placement_destroy_behavior" {
  type        = string
  description = "The destroy behavior for subscription placements. Valid values are 'default', 'parent', 'intermediate_root' or 'custom'."
  default     = "parent"
}

### Combined variable ###

# variable "management_group_settings" {
#   description = "Management group and policy configuration matching the ALZ management_group_settings example."
#   type        = any
#   default = {
#     architecture_name = "alz_custom"
#     location          = "canadacentral"
#     parent_resource_id = ""
#     policy_default_values = {
#       ama_change_tracking_data_collection_rule_id = ""
#       ama_mdfc_sql_data_collection_rule_id        = ""
#       ama_vm_insights_data_collection_rule_id     = ""
#       ama_user_assigned_managed_identity_id       = ""
#       ama_user_assigned_managed_identity_name     = ""
#       log_analytics_workspace_id                  = ""
#       ddos_protection_plan_id                     = ""
#       private_dns_zone_subscription_id            = ""
#       private_dns_zone_region                     = "canadacentral"
#       private_dns_zone_resource_group_name        = ""
#       resource_group_name_service_health_alerts   = ""
#       resource_group_name_mdfc                    = ""
#       resource_group_location                     = "canadacentral"
#       email_security_contact                      = ""
#     }
#     policy_assignments_to_modify = {
#       alz = {
#         policy_assignments = {
#           "Deploy-MDFC-Config-H224" = {
#             parameters = {
#               enableAscForServers                         = "DeployIfNotExists"
#               enableAscForServersVulnerabilityAssessments = "DeployIfNotExists"
#               enableAscForSql                             = "DeployIfNotExists"
#               enableAscForAppServices                     = "DeployIfNotExists"
#               enableAscForStorage                         = "DeployIfNotExists"
#               enableAscForContainers                      = "DeployIfNotExists"
#               enableAscForKeyVault                        = "DeployIfNotExists"
#               enableAscForSqlOnVm                         = "DeployIfNotExists"
#               enableAscForArm                             = "DeployIfNotExists"
#               enableAscForOssDb                           = "DeployIfNotExists"
#               enableAscForCosmosDbs                       = "DeployIfNotExists"
#               enableAscForCspm                            = "DeployIfNotExists"
#             }
#           }
#         }
#       }
#     }
#   }
# }
