variable "certificate_name" {
  description = "(Required) Specifies the name of the Key Vault Certificate."
  type        = string
}

variable "key_vault_id" {
  description = "(Required) The ID of the Key Vault where the Certificate should be created."
  type        = string
}

variable "certificate" {
  description = "(Optional) A certificate block as defined below, used to Import an existing certificate."
  type        = object({
    contents = string
    password = optional(string)
  })
}