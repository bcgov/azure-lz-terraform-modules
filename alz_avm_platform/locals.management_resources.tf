locals {
  /*
  --- Management Resources ---
  You can use this section to customize the management resources that will be deployed.
  */

  # Required Variables
  automation_account_name                  = "bcgov-managed-lz-avm-automation"
  management_resources_resource_group_name = "bcgov-managed-lz-avm-mgmt"

  # Optional Variables
  data_collection_rules = {
    change_tracking = {
      name = "bcgov-managed-lz-avm-dcr-changetracking"
    }
    defender_sql = {
      name = "bcgov-managed-lz-avm-dcr-defendersql"
    }
    vm_insights = {
      name = "bcgov-managed-lz-avm-dcr-vm-insights"
    }
  }
  linked_automation_account_creation_enabled = true
  log_analytics_solution_plans = [
    {
      "product" : "OMSGallery/ContainerInsights",
      "publisher" : "Microsoft"
    },
    {
      "product" : "OMSGallery/VMInsights",
      "publisher" : "Microsoft"
    },
    {
      "product" : "OMSGallery/ChangeTracking",
      "publisher" : "Microsoft"
    },
    {
      "product" : "OMSGallery/LogicAppsManagement",
      "publisher" : "Microsoft"
    },
    {
      "product" : "OMSGallery/NetworkMonitoring",
      "publisher" : "Microsoft"
    }
    # { # This is considered a legacy solution and not available for net-new deployment (though we have it in the current environment).
    #   "product": "OMSGallery/SecurityInsights",
    #   "publisher": "Microsoft"
    # }
  ]

  log_analytics_workspace_daily_quota_gb = -1
  log_analytics_workspace_name           = "bcgov-managed-lz-avm-la"
  # log_analytics_workspace_reservation_capacity_in_gb_per_day = 200 # LIVE `reservation_capacity_in_gb_per_day` can only be used with the `CapacityReservation` SKU
  log_analytics_workspace_retention_in_days = 90
  log_analytics_workspace_sku               = "PerGB2018" # LIVE = CapacityReservation
  # sentinel_onboarding                                        = {} # Set to empty object {} to enable with default values.

  user_assigned_managed_identities = {
    ama = {
      name = "bcgov-managed-lz-avm-uami-ama"
    }
  }
}