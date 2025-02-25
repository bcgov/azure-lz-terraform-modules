data "local_file" "logic_app_trigger_actions_init_affectedresource_var" {
  filename = "${path.module}/logic_app_action_init_affectedresource_var.json"
}

data "local_file" "logic_app_trigger_actions_create_jira_issue" {
  filename = "${path.module}/logic_app_trigger_actions_create_jira_issue.json"
}
