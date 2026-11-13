variable "waf_default_ruleset_parameters" {
  type = object({
    app_gateway_default_ruleset_effect = optional(string, "Audit")
    front_door_default_ruleset_effect  = optional(string, "Audit")
  })
  description = "Parameter values for the WAF-Default-RuleSet policy set assignment."
  default     = {}
}
