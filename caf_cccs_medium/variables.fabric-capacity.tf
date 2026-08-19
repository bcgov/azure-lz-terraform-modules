variable "deny_fabric_capacity_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the Deny-Fabric-Capacity policy assignment."
}
