output "trigger_id" {
  description = "The ID of the Logic App Trigger HTTP Request"
  value       = azurerm_logic_app_trigger_http_request.alerts_logic_app.id
}

output "trigger_callback_url" {
  description = "The Callback URL of the Logic App Trigger HTTP Request"
  value       = azurerm_logic_app_trigger_http_request.alerts_logic_app.callback_url
}
