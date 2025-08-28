variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location."
  nullable    = false
}
variable "condition_monitor" {
  type = map(object({
    name = string
    endpoint = set(object({
      address               = optional(string)
      coverage_level        = optional(string)
      excluded_ip_addresses = optional(set(string))
      included_ip_addresses = optional(set(string))
      name                  = string
      target_resource_id    = optional(string)
      target_resource_type  = optional(string)
      filter = optional(object({
        type = optional(string)
        item = optional(set(object({
          address = optional(string)
          type    = optional(string)
        })))
      }))
    }))
    test_configuration = set(object({
      name                      = string
      preferred_ip_version      = optional(string)
      protocol                  = string
      test_frequency_in_seconds = optional(number)
      http_configuration = optional(object({
        method                   = optional(string)
        path                     = optional(string)
        port                     = optional(number)
        prefer_https             = optional(bool)
        protocol                 = string
        valid_status_code_ranges = optional(set(string))
        request_header = optional(set(object({
          name  = string
          value = string
        })))
      }))
      icmp_configuration = optional(object({
        trace_route_enabled = optional(bool)
      }))
      success_threshold = optional(object({
        checks_failed_percent = optional(number)
        round_trip_time_ms    = optional(number)
      }))
      tcp_configuration = optional(object({
        destination_port_behavior = optional(string)
        port                      = number
        trace_route_enabled       = optional(bool)
      }))
    }))
    test_group = set(object({
      destination_endpoints    = set(string)
      enabled                  = optional(bool)
      name                     = string
      source_endpoints         = set(string)
      test_configuration_names = set(string)
    }))
    notes                         = optional(string, null)
    output_workspace_resource_ids = optional(list(string), null)
  }))
  default     = null
  description = <<DESCRIPTION
  A map of condition monitors to create on the network watcher. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - (Required) The name which should be used for this Network Connection Monitor. Changing this forces a new resource to be created.
  - `location` - (Required) The Azure Region where the Network Connection Monitor should exist. Changing this forces a new resource to be created.
  - `endpoint` - (Required) Set of endpoint configuration for the condition monitor.
    - `address` - (Optional) The IP address or domain name of the Network Connection Monitor endpoint.
    - `coverage_level` - (Optional) The test coverage for the Network Connection Monitor endpoint. Possible values are `AboveAverage`, `Average`, `BelowAverage`, `Default`, `Full` and `Low`.
    - `excluded_ip_addresses` - (Optional) A list of IPv4/IPv6 subnet masks or IPv4/IPv6 IP addresses to be excluded to the Network Connection Monitor endpoint.
    - `included_ip_addresses` - (Optional) A list of IPv4/IPv6 subnet masks or IPv4/IPv6 IP addresses to be included to the Network Connection Monitor endpoint.
    - `name` - (Required) The name of the endpoint for the Network Connection Monitor .
    - `target_resource_id` - (Optional) The resource ID which is used as the endpoint by the Network Connection Monitor.
    - `target_resource_type` - (Optional) The endpoint type of the Network Connection Monitor. Possible values are `AzureArcVM`, `AzureSubnet`, `AzureVM`, `AzureVNet`, `ExternalAddress`, `MMAWorkspaceMachine` and `MMAWorkspaceNetwork`.
    - `filter` supports the following:
      - `type` - (Optional) The behaviour type of this endpoint filter. Currently the only allowed value is `Include`. Defaults to `Include`.
      - `item` supports the following:
        - `address` - (Optional) The address of the filter item.
        - `type` - (Optional) The type of items included in the filter. Possible values are `AgentAddress`. Defaults to `AgentAddress`.
  - `test_configuration` - (Required) Set of Test configuration for the condition monitor.
    - `name` - (Required) The name of test configuration for the Network Connection Monitor.
    - `preferred_ip_version` - (Optional) The preferred IP version which is used in the test evaluation. Possible values are `IPv4` and `IPv6`.
    - `protocol` - (Required) The protocol used to evaluate tests. Possible values are `Tcp`, `Http` and `Icmp`.
    - `test_frequency_in_seconds` - (Optional) The time interval in seconds at which the test evaluation will happen. Defaults to `60`.
    - `http_configuration` (Optional) A HTTP Configuration as
      - `method` - (Optional) The HTTP method for the HTTP request. Possible values are `Get` and `Post`. Defaults to `Get`.
      - `path` - (Optional) The path component of the URI. It only accepts the absolute path.
      - `port` - (Optional) The port for the HTTP connection.
      - `prefer_https` - (Optional) Should HTTPS be preferred over HTTP in cases where the choice is not explicit? Defaults to `false`.
      - `valid_status_code_ranges` - (Optional) The HTTP status codes to consider successful. For instance, `2xx`, `301-304` and `418`.
    - `request_header` supports the following:
      - `name` - (Required) The name of the HTTP header.
      - `value` - (Required) The value of the HTTP header.
    - `icmp_configuration` supports the following:
      - `trace_route_enabled` - (Optional) Should path evaluation with trace route be enabled? Defaults to `true`.
    - `success_threshold` supports the following:
      - `checks_failed_percent` - (Optional) The maximum percentage of failed checks permitted for a test to be successful.
      - `round_trip_time_ms` - (Optional) The maximum round-trip time in milliseconds permitted for a test to be successful.
    - `tcp_configuration` supports the following:
      - `destination_port_behavior` - (Optional) The destination port behavior for the TCP connection. Possible values are `None` and `ListenIfAvailable`.
      - `port` - (Required) The port for the TCP connection.
      - `trace_route_enabled` - (Optional) Should path evaluation with trace route be enabled? Defaults to `true`.
  - `test_group` - (Required) Set of test groups for the condition monitor.
    - `destination_endpoints` - (Required) A list of destination endpoint names.
    - `enabled` - (Optional) Should the test group be enabled? Defaults to `true`.
    - `name` - (Required) The name of the test group for the Network Connection Monitor.
    - `source_endpoints` - (Required) A list of source endpoint names.
    - `test_configuration_names` - (Required) A list of test configuration names.
  - `notes` - (Optional) The description of the Network Connection Monitor.
  - `output_workspace_resource_ids` - (Optional) A list of IDs of the Log Analytics Workspace which will accept the output from the Network Connection Monitor.
  DESCRIPTION
}

variable "flow_logs" {
  type = map(object({
    enabled            = bool
    name               = string
    target_resource_id = string
    retention_policy = object({
      days    = number
      enabled = bool
    })
    storage_account_id = string
    traffic_analytics = optional(object({
      enabled               = bool
      interval_in_minutes   = optional(number)
      workspace_id          = string
      workspace_region      = string
      workspace_resource_id = string
      }), {
      enabled               = false
      interval_in_minutes   = 0
      workspace_id          = null
      workspace_region      = null
      workspace_resource_id = null
    })
    version = optional(number, null)
  }))
  default     = null
  description = <<-EOT

A map of role flow logs to create for the Network Watcher. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
- `enabled` - (Required) Should Network Flow Logging be Enabled?
- `name` - (Required) The name of the Network Watcher Flow Log. Changing this forces a new resource to be created.
- `target_resource_id` - (Required) The ID of the Network Security Group or Virtual Network for which to enable flow logs for. Changing this forces a new resource to be created.
- `network_watcher_name` - (Required) The name of the Network Watcher. Changing this forces a new resource to be created.
- `storage_account_id` - (Required) The ID of the Storage Account where flow logs are stored.
- `version` - (Optional) The version (revision) of the flow log. Possible values are `1` and `2`.
- `retention_policy` Supports the following:
  - `days` - (Required) The number of days to retain flow log records.
  - `enabled` - (Required) Boolean flag to enable/disable retention.
- `traffic_analytics` (Optional) Supports the following:
  - `enabled` - (Required) Boolean flag to enable/disable traffic analytics.
  - `interval_in_minutes` - (Optional) How frequently service should do flow analytics in minutes. Defaults to `60`.
  - `workspace_id` - (Required) The resource GUID of the attached workspace.
  - `workspace_region` - (Required) The location of the attached workspace.
  - `workspace_resource_id` - (Required) The resource ID of the attached workspace.
EOT
}
