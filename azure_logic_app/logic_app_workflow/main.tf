resource "azurerm_resource_group" "alerts_logic_app" {
  name     = var.resource_group_name
  location = var.location
}

# NOTE: Need to use AzAPI as there are limitations with azurerm_api_connection
# See: https://github.com/hashicorp/terraform-provider-azurerm/issues/16818
resource "azapi_resource" "jira" {
  type                      = "Microsoft.Web/connections@2018-07-01-preview"
  name                      = var.api_connection_name
  location                  = azurerm_resource_group.alerts_logic_app.location
  parent_id                 = azurerm_resource_group.alerts_logic_app.id
  schema_validation_enabled = false

  response_export_values = [
    "id",
    "name"
  ]
  body = {
    properties = {
      displayName = var.api_connection_display_name
      parameterValueSet = {
        # name = "APIToken"
        # values = {
        #   username = {
        #     value = var.jira_api_username
        #   }
        #   password = {
        #     value = var.jira_api_token
        #   }
        # }
        name   = "oauth" # IMPORTANT: You will still need to complete the OAuth setup in the Azure Portal post deployment
        values = {}
      }
      api = {
        id = data.azurerm_managed_api.jira.id
      }
    }
  }
}

resource "azurerm_logic_app_workflow" "alerts_logic_app_workflow" {
  name                = var.workflow_name
  location            = azurerm_resource_group.alerts_logic_app.location
  resource_group_name = azurerm_resource_group.alerts_logic_app.name

  workflow_parameters = {
    "$connections" = jsonencode({
      "type" : "Object",
      "defaultValue" : {}
    })
  }

  # NOTE: The workflow connection parameter must be under the same subscription as the workflow.
  parameters = {
    "$connections" = jsonencode({
      jira = { # IMPORTANT: This name must also be the same in the logic_app_action_create_jira_issue.json file under inputs.host.connection.name
        id             = data.azurerm_managed_api.jira.id
        connectionId   = azapi_resource.jira.id
        connectionName = azapi_resource.jira.name
      }
    })
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
