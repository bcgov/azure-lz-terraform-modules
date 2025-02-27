output "action_custom_init_affected_resource_var" {
  description = "The custom action to initialize the affected resource variable"
  value       = azurerm_logic_app_action_custom.init_affected_resource_var
}

output "action_custom_create_jira_issue" {
  description = "The custom action to create a new Jira issue"
  value       = azurerm_logic_app_action_custom.create_jira_issue
}
