# variable "amba_resource_group_name" {
#   type        = string
#   default     = "rg-amba-monitoring-001"
#   description = "The resource group where the resources will be deployed."
# }

# variable "amba_user_assigned_managed_identity_name" {
#   type        = string
#   default     = "id-amba-prod-001"
#   description = "The name of the user-assigned managed identity."

#   validation {
#     condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_-]{1,126}[a-zA-Z0-9]$", var.amba_user_assigned_managed_identity_name))
#     error_message = "The resource name must start with a letter or number, have a length between 3 and 128 characters and can only contain a combination of alphanumeric characters, hyphens and underscores."
#   }
# }

# NOTE: Used with the Logic App created for Azure Monitor alert processing into Jira tickets
# variable "logic_app_resource_id" {
#   type        = string
#   default     = ""
#   description = "The resource ID of the logic app."
# }

# variable "logic_app_callback_url" {
#   type        = string
#   default     = ""
#   description = "The callback URL of the logic app."
# }
