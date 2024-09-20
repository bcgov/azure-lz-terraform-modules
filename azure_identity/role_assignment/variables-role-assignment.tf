variable "role_assignment_scope" {
  description = "(Required) The scope at which the Role Assignment applies to."
  type        = string
}

variable "principal_id" {
  description = "(Required) The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to."
  type        = string  
}

variable "role_definition_id" {
  description = "(Optional) The Scoped-ID of the Role Definition."
  type        = string  
  default = null
}

variable "role_definition_name" {
  description = "(Optional) The name of a built-in Role."
  type        = string  
  default = null  
}