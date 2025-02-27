resource "azurerm_logic_app_action_custom" "init_affected_resource_var" {
  name         = "Initialize_AffectedResource_Variable"
  logic_app_id = var.logic_app_id

  body = data.local_file.logic_app_trigger_actions_init_affectedresource_var.content
}

resource "azurerm_logic_app_action_custom" "create_jira_issue" {
  depends_on = [azurerm_logic_app_action_custom.init_affected_resource_var]

  name         = "Create_a_new_issue_(V3)"
  logic_app_id = var.logic_app_id

  body = data.local_file.logic_app_action_create_jira_issue.content
}

# resource "azurerm_logic_app_action_custom" "create_jira_issue" {
#   depends_on = [ azurerm_logic_app_action_custom.init_affected_resource_var ]

#   name         = "Create_a_new_issue_(V3)"
#   logic_app_id = var.logic_app_id

#   body = jsonencode(data.template_file.create_jira_issue.rendered)
# }
