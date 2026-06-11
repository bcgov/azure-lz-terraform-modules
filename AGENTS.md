# Repository Agent Guidance

This is a public Terraform modules repository.

Do not commit real environment-specific identifiers or operational details, including:

- Azure subscription IDs, tenant IDs, client IDs, or object IDs.
- Backend resource group names, storage account names, container names, or state keys.
- Resource IDs copied from Terraform plans, Azure CLI output, or Azure API errors.
- Internal resource group, virtual hub, network, or project names from forge/live environments.

Use placeholders in public files, for example:

- `<subscription-id>`
- `<tenant-id>`
- `<resource-group-name>`
- `<storage-account-name>`
- `<virtual-hub-name>`

Real backend values belong in private consumer repositories or local-only configuration, not in this modules repository. Before committing, scan new docs, skills, examples, and comments for copied command output that may contain concrete Azure resource IDs.

Modules inside this repository should not source other modules from this same repository using `git::https://github.com/bcgov/azure-lz-terraform-modules.git//...?ref=...`. Use local relative module sources so branch testing remains self-contained.
