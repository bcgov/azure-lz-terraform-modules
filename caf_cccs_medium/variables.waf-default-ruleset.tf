variable "waf_default_ruleset_parameters" {
  type = object({
    app_gateway_default_ruleset_effect = optional(string, "Audit")
    front_door_default_ruleset_effect  = optional(string, "Audit")
    rule_set_version                   = optional(string, "2.2")
  })
  description = "Parameter values for the WAF-Default-RuleSet policy set assignment."
  default     = {}
}
