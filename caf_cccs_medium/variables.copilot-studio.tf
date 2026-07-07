variable "deny_copilot_studio_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the Deny-Copilot-Studio policy assignment."
  default = {
    effect = "Audit"
  }
}
