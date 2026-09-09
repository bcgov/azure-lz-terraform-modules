variable "deny_azure_sre_agent_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the Deny-Azure-SRE-Agent policy assignment."
}
