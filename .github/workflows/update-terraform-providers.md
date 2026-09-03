---
description: "Review Terraform provider constraints, validate this-repo updates, and open a draft PR. Does not change required_version."
run-name: "Update Terraform providers"
labels: ["automation", "terraform"]

on:
  workflow_dispatch:
  schedule:
    - cron: "0 15 * * 1"

permissions:
  contents: read
  issues: read
  pull-requests: read
  copilot-requests: write

engine: copilot

timeout-minutes: 30

network:
  allowed:
    - defaults
    - github
    - terraform

tools:
  github:
    mode: gh-proxy
    toolsets: [default]

skills:
  - .github/skills/update-terraform-providers

safe-outputs:
  create-pull-request:
    title-prefix: "[providers] "
    labels: [provider-updates]
    draft: true
    max: 1
    fallback-as-issue: false
    if-no-changes: ignore
    base-branch: main
    allowed-files:
      - "**/*.tf"
    excluded-files:
      - "**/.terraform.lock.hcl"

pre-agent-steps:
  - uses: hashicorp/setup-terraform@v4
    with:
      terraform_version: "1.13.4"
      terraform_wrapper: false
---

# Update Terraform provider constraints

Review Terraform provider version constraints in this repository and open at most one draft pull request when a compatible provider bump is needed.

This repository is already checked out. Do not clone it again. Do not clone sibling forge or live repos.

## Maintainer notes

Ignore this section when performing the update. It is for humans who operate the workflow.

- Source of truth is this Markdown file. After editing it, recompile with `gh aw compile update-terraform-providers` and commit both this file and `update-terraform-providers.lock.yml`.
- First run after merge: Actions UI or `gh aw run update-terraform-providers`.
- Organization Copilot policy must enable **Copilot CLI** and **Allow use of Copilot CLI billed to the organization** so `copilot-requests: write` can bill through `GITHUB_TOKEN`. If that policy is unavailable, set repository secret `COPILOT_GITHUB_TOKEN`.
- Create the `provider-updates` label in this repository if it does not exist. The safe-output job attaches that label to the draft PR.
- If `terraform init` is firewalled, inspect with `gh aw logs --run-id <id>` or `gh aw audit <id>`, add only the missing domain or ecosystem to `network.allowed`, then recompile.

Security review of compiled actions: the lock file adds `hashicorp/setup-terraform` (SHA-pinned via `.github/aw/actions-lock.json`) only to install Terraform CLI 1.13.4 before the agent starts. No new repository secrets are introduced. Remaining actions are compiler-generated `actions/*` and `github/gh-aw-actions/*` pins.

## Instructions

Follow `.github/skills/update-terraform-providers/SKILL.md` in **Agentic Workflow mode**.

1. Inventory current `required_providers` constraints in `provider.tf`, `providers.tf`, `versions.tf`, `terraform.tf`, and other `*.tf` files.
2. Check latest versions from the Terraform Registry for:
   - `hashicorp/azurerm`
   - `azure/azapi`
   - `hashicorp/azuread`
   - `azure/alz`
   - `azure/modtm`
   - `hashicorp/random`
   - `hashicorp/null`
   - `hashicorp/assert`
   - `XtratusCloud/azureipam`
   - `microsoft/fabric`
3. Update `~>` constraints only when a newer compatible minor exists. Prefer `~> 4.0` style with a space after `=`.
4. Keep exact pins only when there is a documented compatibility reason in the skill (for example `modtm` at `~> 0.3` when a child module requires it).
5. Treat `azureipam` 1.x to 2.x as breaking. Do not bump that major.
6. Leave CAF pins in `caf_cccs_medium/` unchanged, including:
   - `caf_cccs_medium/main.tf`
   - `caf_cccs_medium/modules/core/main.tf`
   - `caf_cccs_medium/modules/connectivity/main.tf`
   - `caf_cccs_medium/modules/management/main.tf`
7. Do not narrow child-module AzureRM ranges that CAF needs, such as `>= 3.112.0, < 5.0.0`.

## Hard rules

- Do **not** change any `required_version`.
- Do **not** edit files that are not Terraform constraint updates.
- Do **not** add `git::https://github.com/bcgov/azure-lz-terraform-modules.git//...?ref=...` sources. Use local relative paths only.
- Do **not** commit or paste real subscription IDs, tenant IDs, client IDs, object IDs, backend storage details, state keys, resource IDs, or forge/live resource names. Use placeholders.
- Do **not** create consumer-repo PRs or clone `azure-lz-core-forge`, `azure-lz-vending-forge`, `azure-lz-vending-live`, or their live counterparts.
- Do **not** call `gh pr create`. Use the `create-pull-request` safe output only.

## Validation

After edits:

```bash
terraform fmt -recursive
terraform fmt -check -recursive
```

For each changed standalone module:

```bash
terraform init -backend=false -input=false -upgrade
terraform validate
```

If validation cannot run, say exactly what was not validated. If validation fails, say so in the PR body and do not claim success.

## Pull request

If one or more provider constraints should change, emit a single `create-pull-request` safe output. The PR body must include:

- Latest provider versions checked
- Provider constraints changed
- CAF or other exceptions left pinned
- Validation commands run and their results

If nothing needs a bump, emit `noop` and do not create a pull request.
