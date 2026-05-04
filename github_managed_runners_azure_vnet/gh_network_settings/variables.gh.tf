# NOTE: Refer to the following documentation for guidance on how to find the GitHub organization ID (aka databaseId)
# https://docs.github.com/en/enterprise-cloud@latest/admin/configuring-settings/configuring-private-networking-for-hosted-compute-products/configuring-private-networking-for-github-hosted-runners-in-your-enterprise#1-obtain-the-databaseid-for-your-enterprise
variable "github_organization_id" {
  description = "(Required) The GitHub business (enterprise/organization) ID associated to the Azure subscription"
  type        = string

  validation {
    condition     = length(var.github_organization_id) > 0
    error_message = "The GitHub organization ID must not be empty."
  }
}

variable "network_settings_name" {
  description = "The name of the GitHub Network Settings resource"
  type        = string

  validation {
    condition     = length(var.network_settings_name) > 0
    error_message = "The network settings name must not be empty."
  }
}

variable "github_hosted_runners_resource_group_id" {
  description = "The Resource Group ID where the GitHub runners will be deployed"
  type        = string
}

variable "github_hosted_runners_subnet_id" {
  description = "The subnet ID where the GitHub runners will be deployed"
  type        = string
}
