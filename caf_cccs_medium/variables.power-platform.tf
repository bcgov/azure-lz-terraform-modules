variable "deny_power_platform_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the Deny-Power-Platform policy assignment."
  default = {
    effect = "Audit"
  }
}
