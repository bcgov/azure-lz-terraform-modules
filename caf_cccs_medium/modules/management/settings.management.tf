# Configure custom management resources settings
locals {
  configure_management_resources = {
    settings = {
      log_analytics = {
        config = {
          # Set a custom number of days to retain logs
          retention_in_days = var.log_retention_in_days
          # reservation_capacity_in_gb_per_day = 200
          # daily_quota_gb = 200
        }
      }
      security_center = {
        config = {
          # Configure a valid security contact email address
          email_security_contact         = var.email_security_contact
          enable_defender_for_containers = false
        }
      }
    }
    # Set the default location
    location = var.primary_location
    # Create a custom tags input
    tags = var.management_resources_tags

    advanced = {
      custom_settings_by_resource_type = {
        azurerm_log_analytics_workspace = var.log_analytics_workspace_settings != null ? {
          "management" = var.log_analytics_workspace_settings
        } : {}
      }
    }
  }
}
