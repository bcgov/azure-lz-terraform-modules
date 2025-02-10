# Configure custom management resources settings
locals {
  configure_management_resources = {
    settings = {
      # log_analytics = {
      #   config = {
      #     # Set a custom number of days to retain logs
      #     retention_in_days = var.log_retention_in_days
      #   }
      # }
      security_center = {
        config = {
          # Configure a valid security contact email address
          email_security_contact = var.email_security_contact
        }
      }
    }
    # Set the default location
    location = var.primary_location
    # Create a custom tags input
    tags = var.management_resources_tags

    advanced = {

      existing_log_analytics_workspace_resource_id = var.existing_log_analytics_workspace_resource_id
    }
  }
}
