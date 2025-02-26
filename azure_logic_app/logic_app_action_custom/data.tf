data "local_file" "logic_app_trigger_actions_init_affectedresource_var" {
  filename = "${path.module}/logic_app_action_init_affectedresource_var.json"
}

data "local_file" "logic_app_action_create_jira_issue" {
  filename = "${path.module}/logic_app_action_create_jira_issue.json"
  # IMPORANT: The inputs.host.connection.name value should match the azurerm_logic_app_workflow.parameters.$connections map object name
}

# data "template_file" "create_jira_issue" {
#   template = "${file("${path.module}/logic_app_action_create_jira_issue.tpl")}"
#   vars = {
#     api_connection_name = "${var.api_connection_name}"
#   }
# }
