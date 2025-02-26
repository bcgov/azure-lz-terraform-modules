module "logic_app_workflow" {
  source = "../logic_app_workflow"

  resource_group_name = var.resource_group_name
  location            = var.location

  workflow_name = var.workflow_name
  api_connection_name = var.api_connection_name
  api_connection_display_name = var.api_connection_display_name
  jira_api_username = var.jira_api_username
  jira_api_token = var.jira_api_token
}

module "logic_app_trigger_http_request" {
  source = "../logic_app_trigger_http_request"

  logic_app_id = module.logic_app_workflow.logic_app_id  
}

module "logic_app_action_custom" {
  source = "../logic_app_action_custom"
  depends_on = [ module.logic_app_trigger_http_request ]

  logic_app_id = module.logic_app_workflow.logic_app_id
  api_connection_name = var.api_connection_name
}
