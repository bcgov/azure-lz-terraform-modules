locals {
  policy_default_values = {
    amba_alz_management_subscription_id = jsonencode({
      value = local.subscription_id_management != "" ? local.subscription_id_management : data.azapi_client_config.current.subscription_id
    })
    amba_alz_resource_group_location             = jsonencode({ value = local.location })
    amba_alz_resource_group_name                 = jsonencode({ value = local.amba_resource_group_name })
    amba_alz_user_assigned_managed_identity_name = jsonencode({ value = local.amba_user_assigned_managed_identity_name })

    # NOTE: Used with the Logic App created for Azure Monitor alert processing into Jira tickets
    # amba_alz_logicapp_resource_id                  = jsonencode({ value = local.logic_app_resource_id })
    # amba_alz_logicapp_callback_url                 = jsonencode({ value = local.logic_app_callback_url })

    log_analytics_workspace_id = jsonencode({ value = provider::azapi::resource_group_resource_id(local.subscription_id_management, local.management_resources_resource_group_name, "Microsoft.OperationalInsights/workspaces", [local.log_analytics_workspace_name]) })
    # TODO Figure out what property is needed to set email_security_contact = "cloud.pathfinder@gov.bc.ca"
    # NOTE: Unable to find documentation for this property. Deduced from existing CAF implementation.
    # `terraform plan` shows this is linked with the bcgov-managed-lz-avm/Deploy-MDFC-Config-H224 policy assignment, and the `emailSecurityContact` parameter.
    # email_security_contact = jsonencode({ value = local.email_security_contact })
  }

  policy_assignments_to_modify = {
    bcgov-managed-lz-avm = { # Management Group ID
      policy_assignments = {
        # TESTING: [Preview]: Deploy Microsoft Defender for Endpoint agent (Initiative)
        Deploy-MDEndpoints = { # Policy Assignment Name
          parameters = {
            microsoftDefenderForEndpointWindowsVmAgentDeployEffect = jsonencode({ value = "AuditIfNotExists" })
          }
        },
        Deploy-MDFC-Config-H224 = { # Policy Assignment Name
          parameters = {
            emailSecurityContact = jsonencode({ value = local.email_security_contact })
          }
        }
      }
    }
  }
}