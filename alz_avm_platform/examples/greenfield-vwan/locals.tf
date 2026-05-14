locals {
  # Example: assignment-level customizations for built-in or custom policy assignments.
  # Keep this in locals for readability because the structure can be large.
  policy_assignments_to_modify = {
    # enforce-encryption-storage = {
    #   enforcement_mode = "DoNotEnforce"
    #   non_compliance_messages = [
    #     {
    #       message = "Storage encryption is required by platform baseline policy."
    #     }
    #   ]
    # }
  }
}
