/*
--- Management Resources ---
You can use this section to customize the management resources that will be deployed.
*/

resource_group_name = "bcgov-managed-lz-avm-mgmt"

log_analytics_workspace_name              = "bcgov-managed-lz-avm-la"
log_analytics_workspace_retention_in_days = 90
log_analytics_workspace_daily_quota_gb    = 100
log_analytics_workspace_sku               = "PerGB2018"
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
  # {
  #   "product": "OMSGallery/SecurityInsights",
  #   "publisher": "Microsoft"
  # }
]

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

automation_account_name                    = "bcgov-managed-lz-avm-aa"
linked_automation_account_creation_enabled = true
