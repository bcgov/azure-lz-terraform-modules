locals {
  parent_resource_id = "BCGOV-MGD-LZ" # NOTE: This is our team's "tenant root" management group that all other management groups will be created under.
}

locals {
  /*
  --- Management Groups and Policy ---
  You can use this section to customize the management groups and policies that will be deployed.
  You can further configure management groups and policy by supplying a `lib` folder. This is detailed in the Accelerator documentation.
  */
  management_groups_enabled = true

  management_group_settings = {
    # This is the name of the architecture that will be used to deploy the management resources.
    # It refers to the alz_custom.alz_architecture_definition.yaml file in the lib folder.
    # Do not change this value unless you have created another architecture definition
    # with the name value specified below.
    architecture_name  = "alz_custom"
    location           = "$${starter_location_01}"
    parent_resource_id = "$${root_parent_management_group_id}"
    policy_default_values = {
      ama_change_tracking_data_collection_rule_id = "$${ama_change_tracking_data_collection_rule_id}"
      ama_mdfc_sql_data_collection_rule_id        = "$${ama_mdfc_sql_data_collection_rule_id}"
      ama_vm_insights_data_collection_rule_id     = "$${ama_vm_insights_data_collection_rule_id}"
      ama_user_assigned_managed_identity_id       = "$${ama_user_assigned_managed_identity_id}"
      ama_user_assigned_managed_identity_name     = "$${ama_user_assigned_managed_identity_name}"
      log_analytics_workspace_id                  = "$${log_analytics_workspace_id}"
      ddos_protection_plan_id                     = "$${ddos_protection_plan_id}"
      private_dns_zone_subscription_id            = "$${subscription_id_connectivity}"
      private_dns_zone_region                     = "$${starter_location_01}"
      private_dns_zone_resource_group_name        = "$${dns_resource_group_name}"
      resource_group_name_service_health_alerts   = "$${service_health_alerts_resource_group_name}"
      resource_group_name_mdfc                    = "$${asc_export_resource_group_name}"
      resource_group_location                     = "$${starter_location_01}"
      email_security_contact                      = "$${defender_email_security_contact}"
      /*
      # Example of allowed locations for Sovereign Landing Zones policies
      allowed_locations = [
        "$${starter_location_01}",
        "$${starter_location_02}"
      ]
      */
    }
    # subscription_placement = {
    #   connectivity = {
    #     subscription_id       = "$${subscription_id_connectivity}"
    #     management_group_name = "bcgov-managed-lz-avm-connectivity"
    #   }
    #   identity = {
    #     subscription_id       = "$${subscription_id_identity}"
    #     management_group_name = "bcgov-managed-lz-avm-identity"
    #   }
    #   management = {
    #     subscription_id       = "$${subscription_id_management}"
    #     management_group_name = "bcgov-managed-lz-avm-management"
    #   }
    #   security = {
    #     subscription_id       = "$${subscription_id_security}"
    #     management_group_name = "bcgov-managed-lz-avm-security"
    #   }
    # }
    policy_assignments_to_modify = {
      alz = {
        policy_assignments = {
          Deploy-MDFC-Config-H224 = {
            parameters = {
              enableAscForServers                         = "DeployIfNotExists"
              enableAscForServersVulnerabilityAssessments = "DeployIfNotExists"
              enableAscForSql                             = "DeployIfNotExists"
              enableAscForAppServices                     = "DeployIfNotExists"
              enableAscForStorage                         = "DeployIfNotExists"
              enableAscForContainers                      = "DeployIfNotExists"
              enableAscForKeyVault                        = "DeployIfNotExists"
              enableAscForSqlOnVm                         = "DeployIfNotExists"
              enableAscForArm                             = "DeployIfNotExists"
              enableAscForOssDb                           = "DeployIfNotExists"
              enableAscForCosmosDbs                       = "DeployIfNotExists"
              enableAscForCspm                            = "DeployIfNotExists"
            }
          }
        }
      }
    }
    /*
    # Example of how to add management group role assignments
    management_group_role_assignments = {
      root_owner_role_assignment = {
        management_group_name      = "root"
        role_definition_id_or_name = "Owner"
        principal_id               = "00000000-0000-0000-0000-000000000000"
      }
    }
    */
    # role_assignment_name_use_random_uuid = false  # Uncomment this for backwards compatibility with previous naming convention
  }
}
