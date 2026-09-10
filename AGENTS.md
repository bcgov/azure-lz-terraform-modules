# Repository Agent Guidance

This is a public Terraform modules repo.

- Do not commit real environment identifiers: subscription IDs, tenant IDs, client IDs, object IDs, backend storage details, state keys, resource IDs, or forge/live resource names. Use placeholders like `<subscription-id>` and `<resource-group-name>`.
- Do not paste raw Terraform, Azure CLI, or Azure API output into committed docs unless environment-specific values are redacted.
- Modules in this repo must not source this same repo with `git::https://github.com/bcgov/azure-lz-terraform-modules.git//...?ref=...`; use local relative paths instead.
- Be careful with `caf_cccs_medium`: keep CAF provider pins compatible with `Azure/caf-enterprise-scale/azurerm` unless a CAF upgrade is explicitly requested. Validate CAF-impacting changes through a real consumer root.
- Azure Policy assignment names must be 24 characters or fewer (`Microsoft.Authorization/policyAssignments.name`); enforce this limit when introducing or renaming assignments.
- Run `terraform fmt -recursive` after Terraform edits. For changed standalone modules, prefer `terraform init -backend=false -upgrade` and `terraform validate` when practical.
- Keep private backend values and live/forge rollout changes in the private consumer repos, not in this public module repo.
