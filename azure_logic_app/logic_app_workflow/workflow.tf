resource "azurerm_logic_app_workflow" "alerts_logic_app_workflow" {
  name                = var.workflow_name
  location            = azurerm_resource_group.alerts_logic_app.location
  resource_group_name = azurerm_resource_group.alerts_logic_app.name

  workflow_parameters = var.workflow_parameters
  workflow_schema     = var.workflow_schema
  workflow_version    = var.workflow_version
  parameters          = var.parameters
}
