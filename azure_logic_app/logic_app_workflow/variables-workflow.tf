variable "workflow_name" {
  description = "The name of the Logic App workflow."
  type        = string
}

variable "workflow_parameters" {
  description = "(Optional) A map of Key-Value pairs of the Parameter Definitions to use for this Logic App Workflow. The key is the parameter name, and the value is a JSON encoded string of the parameter definition."
  type        = map(string)
  default     = null
}

variable "workflow_schema" {
  description = "(Optional) Specifies the Schema to use for this Logic App Workflow."
  type        = string
  default     = null
}

variable "workflow_version" {
  description = "(Optional) Specifies the version of the Schema used for this Logic App Workflow. Defaults to 1.0.0.0."
  type        = string
  default     = null
}

variable "parameters" {
  description = "(Optional) A map of Key-Value pairs. Any parameters specified must exist in the Schema defined in workflow_parameters."
  type        = map(string)
  default     = null
}
