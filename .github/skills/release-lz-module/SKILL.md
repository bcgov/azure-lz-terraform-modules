---
name: release-lz-module
description: Coordinate Azure landing zone module releases across azure-lz-terraform-modules, azure-lz-vending-live, and azure-lz-core-live. Use when tagging module releases, bumping module refs, updating generated project-set consumers, preparing release PRs, or rolling module changes into live landing zone deployments.
---

# Release LZ Module

## Repositories

This workflow must work in a greenfield environment. Do not assume sibling clones already exist.

Use the GitHub CLI for repository operations:

```bash
gh auth status
export LZ_WORKDIR="${LZ_WORKDIR:-$(mktemp -d /tmp/lz-release-work.XXXXXX)}"

gh repo clone bcgov/azure-lz-terraform-modules "$LZ_WORKDIR/azure-lz-terraform-modules"
gh repo clone bcgov/azure-lz-vending-live "$LZ_WORKDIR/azure-lz-vending-live"
gh repo clone bcgov/azure-lz-core-live "$LZ_WORKDIR/azure-lz-core-live"

export MODULES_REPO="$LZ_WORKDIR/azure-lz-terraform-modules"
export VENDING_REPO="$LZ_WORKDIR/azure-lz-vending-live"
export CORE_REPO="$LZ_WORKDIR/azure-lz-core-live"
```

If a repo is already present, set the relevant environment variable to that path instead of cloning again. If cloning is needed, clone under `/tmp` and remove `LZ_WORKDIR` after the operation is complete. If `gh auth status` fails, stop and ask the user to authenticate.

Repository roles:

- `bcgov/azure-lz-terraform-modules`: reusable Terraform module library and release tags.
- `bcgov/azure-lz-vending-live`: project-set vending live repo with generated `projects/<license_plate>/main.tf` files.
- `bcgov/azure-lz-core-live`: platform-wide live repo with independently pinned module consumers.

## Release Shape

Module releases are consumed by git tags, usually as:

```hcl
source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//<module_path>?ref=vX.Y.Z"
```

`azure-lz-vending-live` uses `config.json.version` plus templates and concrete `projects/<license_plate>` Terraform files. Use the repo's `scripts/retemplate-projects.sh` helper to regenerate project files after version/template changes.

`azure-lz-core-live` pins module refs directly inside each service directory, so core areas can be on different module tags at the same time.

## Quick Workflow

1. In `azure-lz-terraform-modules`, review the intended release diff and affected module paths.
2. Check whether the change is backwards-compatible for existing state.
3. If state addresses or provider schemas changed, design a migration before bumping live repos.
4. Create or identify the release tag in `azure-lz-terraform-modules`.
5. In `$VENDING_REPO`, update `config.json.version` to the release tag whenever project-set modules should move. This is the canonical vending module version and must not lag behind generated `projects/*/main.tf` refs.
6. Run `$VENDING_REPO/scripts/retemplate-projects.sh --dry-run`, then run `./scripts/retemplate-projects.sh` or `./scripts/retemplate-projects.sh --all` as appropriate. If the repo has no helper script, manually align every generated `projects/*/main.tf` module ref with `config.json.version`.
7. Review generated project diffs and confirm `config.json.version` matches those refs before creating the vending PR.
8. In `$CORE_REPO`, update only the relevant `?ref=` pins for affected core service directories.
9. Run `terraform fmt -recursive` in each modified repo.
10. Prepare PRs with `gh pr create`; keep module release, vending rollout, and core rollout separated when risk or ownership differs.

Do not bulk-update core-live refs that are unrelated to the module change.

## Tags And PRs

Use `gh` for GitHub-facing repo actions.

Check for an existing tag/release:

```bash
gh release view vX.Y.Z --repo bcgov/azure-lz-terraform-modules
```

If the release tag must be created, prefer a GitHub release so the tag is visible and auditable:

```bash
gh release create vX.Y.Z --repo bcgov/azure-lz-terraform-modules --target <commit-sha> --title vX.Y.Z --notes-file <notes-file>
```

Create rollout PRs with `gh pr create` from the changed repo working tree:

```bash
gh pr create --repo bcgov/azure-lz-vending-live --title "Update landing zone modules to vX.Y.Z" --body-file <body-file>
gh pr create --repo bcgov/azure-lz-core-live --title "Update <service> module refs to vX.Y.Z" --body-file <body-file>
```

## Vending-Live Details

Important files:

- `$VENDING_REPO/config.json`: source of the fleet module tag via `version`.
- `$VENDING_REPO/templates/main.tf.tmpl`: generated project-set root module template.
- `$VENDING_REPO/templates/backend.tf.tmpl`: generated backend template.
- `$VENDING_REPO/projects/<license_plate>/main.tf`: generated consumer files.
- `$VENDING_REPO/scripts/retemplate-projects.sh`: canonical project regeneration helper.

Use:

```bash
cd "$VENDING_REPO"
./scripts/retemplate-projects.sh --dry-run
./scripts/retemplate-projects.sh
```

Use `--all` only when backend template values or backend generation changed:

```bash
./scripts/retemplate-projects.sh --all
```

After vending-live changes, inspect the diff for generated-only changes. A `config.json` change can trigger all projects in CI, so call that out in the PR. Never update generated project refs without also updating `config.json.version` to the same release tag.

## Core-Live Details

Important consumers include:

- `$CORE_REPO/caf/main.tf`
- `$CORE_REPO/azure_private_dns/main.tf`
- `$CORE_REPO/azure_monitor_baseline_alerts/main.tf`
- `$CORE_REPO/azure_firewall/*/*.tf`
- `$CORE_REPO/azure_vwan/*`
- `$CORE_REPO/azure_network_watcher/*`
- `$CORE_REPO/finops_toolkit/*`

Search for module refs before editing:

```bash
rg 'azure-lz-terraform-modules.*ref=' "$CORE_REPO"
```

Update only refs for modules affected by the release. Keep existing local-testing source comments intact; do not depend on them for this workflow.

## State Migration Gate

Before rolling a tag to live repos, decide whether state migration is required:

- Resource addresses changed, moved, renamed, or split.
- Provider major version changed state schema.
- Resources were replaced with data sources, null resources, or local-exec wrappers.
- Module `for_each` keys changed.
- Existing live resources would be destroyed/recreated unexpectedly.

If migration is required, follow the existing pattern from `$VENDING_REPO/scripts/migrate-azure-ad-groups-state.sh`: dry-run first, pull timestamped backups, filter anchored addresses, and avoid `apply` or `destroy` in migration scripts.

## GitHub Actions

Use `gh` to inspect and operate PRs and workflow runs:

```bash
gh pr status --repo bcgov/azure-lz-vending-live
gh run list --repo bcgov/azure-lz-vending-live --limit 20
gh run view <run-id> --repo bcgov/azure-lz-vending-live --log-failed
```

Use the appropriate `--repo` value for `bcgov/azure-lz-terraform-modules` and `bcgov/azure-lz-core-live`.

## Validation

Use the narrowest validation that exercises the changed surface:

```bash
terraform fmt -recursive
terraform validate
```

For live repos, prefer CI plans for real backend/auth validation. Local validation may fail if the operator lacks Azure permissions or backend access.

For vending-wide changes, expect a project matrix. Summarize the scope and mention whether every project was regenerated.

## PR Notes

Call out:

- Module tag being consumed.
- Affected module paths.
- Whether vending `config.json.version`, templates, or concrete project files were updated, and whether the config version matches generated refs.
- Which core-live service directories were bumped.
- Whether state migration is needed, already completed, or intentionally not needed.
- Expected CI blast radius.

## Cleanup

If temporary clones were created for the workflow, remove them after PRs are created or the investigation is complete:

```bash
rm -rf "$LZ_WORKDIR"
```
