# Copilot Instructions

This repository contains reusable Terraform modules for BC Gov Azure landing zone deployments. Treat it as a public module source for downstream consumer repos.

Follow the repository guidance in `AGENTS.md`.

## Security And Public Repo Hygiene

- Do not suggest or commit real Azure subscription IDs, tenant IDs, client IDs, object IDs, backend storage details, state keys, resource IDs, or environment-specific forge/live resource names in docs, examples, comments, skills, or tests.
- Use placeholders such as `<subscription-id>`, `<tenant-id>`, `<resource-group-name>`, `<storage-account-name>`, `<state-key>`, and `<virtual-hub-name>`.
- Do not paste raw Terraform plan/init output, Azure CLI output, or Azure API errors into committed files unless environment-specific identifiers are redacted first.

## Repository Rules

- Use `gh` for GitHub repository operations, PRs, releases, workflow inspection, and cross-repo work.
- Do not assume sibling repositories are checked out locally.
- When another repo is needed, clone it with `gh repo clone` into a temporary `/tmp` workdir created with `mktemp -d`, and clean it up with `rm -rf "$LZ_WORKDIR"` when done.
- Do not run destructive Terraform or git commands unless the user explicitly asks and the impact is clear.
- Keep edits scoped to the requested module or workflow. Do not reformat unrelated files.
- Prefer existing Terraform patterns, provider aliases, comments, and module boundaries.
- Do not add same-repository Git module sources such as `git::https://github.com/bcgov/azure-lz-terraform-modules.git//...?ref=...` from modules in this repo. Use local relative sources instead.
- For Azure Policy assignments, keep `name` at 24 characters or fewer to avoid ALZ/CAF assignment rendering failures.

## Terraform Validation

Run formatting after Terraform edits:

```bash
terraform fmt -recursive
terraform fmt -check -recursive
```

For changed standalone modules, validate from the module directory when possible:

```bash
terraform init -backend=false -input=false -upgrade
terraform validate
```

If validation cannot run because of Azure auth, backend access, registry/network limits, or provider constraints, report exactly what was not validated.

## Provider Updates

Use `.github/skills/update-terraform-providers/SKILL.md` for provider-version work. Be careful with `caf_cccs_medium/`; do not force CAF azurerm 3.x consumers to azurerm 4.x without explicit approval.

## Module Releases

Use `.github/skills/release-lz-module/SKILL.md` for releases and downstream rollouts. For vending-live rollouts, use the repo's `scripts/retemplate-projects.sh` helper after updating `config.json.version` or templates, and review generated project diffs before creating a PR.
