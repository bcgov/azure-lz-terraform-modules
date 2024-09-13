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

variable "configure_identity_resources" {
  type = object({
    settings = optional(object({
      identity = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          enable_deny_public_ip             = optional(bool, true)
          enable_deny_rdp_from_internet     = optional(bool, true)
          enable_deny_subnet_without_nsg    = optional(bool, true)
          enable_deploy_azure_backup_on_vms = optional(bool, true)
        }), {})
      }), {})
    }), {})
  })
  description = "If specified, will customize the \"Identity\" landing zone settings."
  default     = {}
}

variable "archetype_config_overrides" {
  type        = any
  description = <<DESCRIPTION
If specified, will set custom Archetype configurations for the core ALZ Management Groups.
Does not work for management groups specified by the 'custom_landing_zones' input variable.
To override the default configuration settings for any of the core Management Groups, add an entry to the archetype_config_overrides variable for each Management Group you want to customize.
To create a valid archetype_config_overrides entry, you must provide the required values in the archetype_config_overrides object for the Management Group you wish to re-configure.
To do this, simply create an entry similar to the root example below for one or more of the supported core Management Group IDs:

- root
- decommissioned
- sandboxes
- landing-zones
- platform
- connectivity
- management
- identity
- corp
- online
- sap

```terraform
map(
  object({
    archetype_id     = string
    enforcement_mode = map(bool)
    parameters       = map(any)
    access_control   = map(list(string))
  })
)
```

e.g.

```terraform
  archetype_config_overrides = {
    root = {
      archetype_id = "root"
      enforcement_mode = {
        "Example-Policy-Assignment" = true,
      }
      parameters = {
        Example-Policy-Assignment = {
          parameterStringExample = "value1",
          parameterBoolExample   = true,
          parameterNumberExample = 10,
          parameterListExample = [
            "listItem1",
            "listItem2",
          ]
          parameterObjectExample = {
            key1 = "value1",
            key2 = "value2",
          }
        }
      }
      access_control = {
        Example-Role-Definition = [
          "00000000-0000-0000-0000-000000000000", # Object ID of user/group/spn/mi from Microsoft Entra ID
          "11111111-1111-1111-1111-111111111111", # Object ID of user/group/spn/mi from Microsoft Entra ID
        ]
      }
    }
  }
```
DESCRIPTION
  default     = {}
}
