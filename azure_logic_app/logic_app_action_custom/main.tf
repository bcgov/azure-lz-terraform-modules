resource "azurerm_logic_app_action_custom" "init_affected_resource_var" {
  name         = "Initialize_AffectedResource_Variable"
  logic_app_id = var.logic_app_id

  body = data.local_file.logic_app_trigger_actions_init_affectedresource_var.content
}

resource "azurerm_logic_app_action_custom" "create_jira_issue" {
  depends_on = [azurerm_logic_app_action_custom.init_affected_resource_var]

  name         = "Condition_(NOT_Sev3_or_Sev4)"
  logic_app_id = var.logic_app_id

  body = data.local_file.logic_app_action_create_jira_issue.content
}
