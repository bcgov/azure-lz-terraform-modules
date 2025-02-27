output "workflow" {
  description = "The Logic App Workflow object."
  value       = azurerm_logic_app_workflow.alerts_logic_app_workflow
}

output "logic_app_id" {
  description = "The ID of the Logic App."
  value       = azurerm_logic_app_workflow.alerts_logic_app_workflow.id
}
