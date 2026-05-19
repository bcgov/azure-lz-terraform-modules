variable "sqlmi_disable_public_endpoint_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the SQLMI-Disable-PublicData policy assignment."
}

variable "sqlmi_entra_authentication_parameters" {
  type = object({
    effect = string
  })
  description = "Parameter values for the SQLMI-Entra-AuthN policy assignment."
}
