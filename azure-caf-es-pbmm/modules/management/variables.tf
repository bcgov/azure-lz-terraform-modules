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

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
}

variable "email_security_contact" {
  type        = string
  description = "Set a custom value for the security contact email address."
}

variable "log_retention_in_days" {
  type        = number
  description = "Set a custom value for how many days to store logs in the Log Analytics workspace."
}

variable "management_resources_tags" {
  type        = map(string)
  description = "Specify tags to add to \"management\" resources."
}

variable "configure_management_resources" {
  type = object({
    settings = optional(object({
      ama = optional(object({
        enable_uami                                                         = optional(bool, true)
        enable_vminsights_dcr                                               = optional(bool, true)
        enable_change_tracking_dcr                                          = optional(bool, true)
        enable_mdfc_defender_for_sql_dcr                                    = optional(bool, true)
        enable_mdfc_defender_for_sql_query_collection_for_security_research = optional(bool, true)
      }), {})
      log_analytics = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          retention_in_days                      = optional(number, 30)
          enable_monitoring_for_vm               = optional(bool, true)
          enable_monitoring_for_vmss             = optional(bool, true)
          enable_sentinel                        = optional(bool, true)
          enable_change_tracking                 = optional(bool, true)
          enable_solution_for_vm_insights        = optional(bool, true)
          enable_solution_for_container_insights = optional(bool, true)
          sentinel_customer_managed_key_enabled  = optional(bool, false) # not used at this time
        }), {})
      }), {})
      security_center = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          email_security_contact                                = optional(string, "security_contact@replace_me")
          enable_defender_for_app_services                      = optional(bool, true)
          enable_defender_for_arm                               = optional(bool, true)
          enable_defender_for_containers                        = optional(bool, true)
          enable_defender_for_cosmosdbs                         = optional(bool, true)
          enable_defender_for_cspm                              = optional(bool, true)
          enable_defender_for_key_vault                         = optional(bool, true)
          enable_defender_for_oss_databases                     = optional(bool, true)
          enable_defender_for_servers                           = optional(bool, true)
          enable_defender_for_servers_vulnerability_assessments = optional(bool, true)
          enable_defender_for_sql_servers                       = optional(bool, true)
          enable_defender_for_sql_server_vms                    = optional(bool, true)
          enable_defender_for_storage                           = optional(bool, true)
        }), {})
      }), {})
    }), {})
    location = optional(string, "")
    tags     = optional(any, {})
    advanced = optional(any, {})
  })
  description = "If specified, will customize the \"Management\" landing zone settings and resources."
  default     = {}
}
