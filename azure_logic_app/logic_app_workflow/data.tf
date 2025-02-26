data "azurerm_managed_api" "jira" {
  name     = "jira"
  location = azurerm_resource_group.alerts_logic_app.location
}
