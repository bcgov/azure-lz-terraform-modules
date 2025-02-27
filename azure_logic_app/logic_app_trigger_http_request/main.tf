resource "azurerm_logic_app_trigger_http_request" "alerts_logic_app" {
  name         = "When_a_HTTP_request_is_received"
  logic_app_id = var.logic_app_id

  schema = data.local_file.logic_app_trigger_http_request.content
}
