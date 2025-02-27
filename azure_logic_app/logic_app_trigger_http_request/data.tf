data "local_file" "logic_app_trigger_http_request" {
  filename = "${path.module}/logic_app_trigger_http_request.json"
  # NOTE: This file should contain the Common Alert Schema
  # See: https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/alerts-common-schema
}
