variable "managed_by" {
  description = "Value stored in exemption metadata as managedBy."
  type        = string
}

variable "review_by" {
  description = "Next review date (YYYY-MM-DD) stored as reviewBy on exemptions with no expires_on."
  type        = string
}

variable "exemptions" {
  description = "Policy exemptions to import and manage. scope_type is subscription, resource_group, or resource. An empty policy_definition_reference_ids list waives the whole assignment. reviewers is a list of email addresses. extra holds metadata keys that only this exemption has."
  type = map(object({
    scope_type                      = string
    scope_id                        = string
    name                            = string
    policy_assignment_id            = string
    display_name                    = string
    description                     = string
    policy_definition_reference_ids = list(string)
    exemption_category              = string
    expires_on                      = optional(string)
    reviewers                       = optional(list(string), [])
    last_reviewed_on                = optional(string)
    reason                          = optional(string)
    ticket                          = optional(string)
    extra                           = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for v in values(var.exemptions) : contains(["subscription", "resource_group", "resource"], v.scope_type) && startswith(v.scope_id, "/")
    ])
    error_message = "scope_type must be subscription, resource_group, or resource, and scope_id must be an ARM id."
  }

  validation {
    condition = alltrue([
      for v in values(var.exemptions) : contains(["Waiver", "Mitigated"], v.exemption_category)
    ])
    error_message = "exemption_category must be Waiver or Mitigated."
  }

  validation {
    condition = alltrue([
      for v in values(var.exemptions) : alltrue([
        for email in coalesce(v.reviewers, []) : can(regex("^[^@[:space:]]+@[^@[:space:]]+[.][^@[:space:]]+$", email))
      ])
    ])
    error_message = "reviewers must be a list of email addresses."
  }
}
