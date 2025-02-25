resource "azurerm_logic_app_action_custom" "init_affected_resource_var" {
  name         = "Initialize_AffectedResource_Variable"
  logic_app_id = azurerm_logic_app_workflow.example.id

  body = data.local_file.logic_app_trigger_actions_init_affectedresource_var.content
}

resource "azurerm_logic_app_action_custom" "create_jira_issue" {
  name         = "Create_a_new_issue_(V3)"
  logic_app_id = azurerm_logic_app_workflow.example.id

  body = data.local_file.logic_app_trigger_actions_create_jira_issue.content
}
