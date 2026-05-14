# AzPolicyLens – Policy Documentation

This directory contains the BC Gov Forge implementation of [Azure/AzPolicyLens](https://github.com/Azure/AzPolicyLens), an Azure policy documentation generator that discovers Azure Policy assignments and produces GitHub Wiki pages.

## Directory Structure

```
azure_policy_lens/
├── configurations/          # Environment config (settings.yml, github-config.jsonc, schema, metadata)
├── ps_modules/              # Vendored PowerShell modules
│   ├── AzPolicyLens.Discovery/
│   └── AzPolicyLens.Wiki/
└── scripts/
    └── pipelines/
        └── policy-documentation/   # Pipeline PowerShell scripts
```

The workflow and composite action templates live under `.github/`:

```
.github/
├── actions/templates/
│   ├── initiation/
│   ├── policyDocDiscovery/
│   ├── policyDocParseConfig/
│   └── policyDocGenerateWiki/
└── workflows/
    └── policy-documentation.yml
```

---

## Differences from Upstream (Azure/AzPolicyLens)

### 1. Single Environment vs. Multiple Environments

| Upstream | This repo |
|---|---|
| Two environments (`dev`, `prod`) with separate discovery, parse, and generate jobs for each | Single environment (`forge`) — three jobs: `job_discovery_forge`, `job_parse_config_forge`, `job_generate_wiki_forge` |

The upstream workflow is parameterized for multi-environment pipelines. This implementation scopes to the `forge` landing zone only (`bcgov-managed-lz-forge` management group).

### 2. Authentication

| Upstream | This repo |
|---|---|
| Service principal credentials stored as `AZURE_CREDENTIALS` JSON secret | OIDC federation via `azure/login@v2` using three discrete secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |

OIDC is preferred as it avoids long-lived credentials. The workflow sets `ARM_USE_OIDC: true`.

### 3. GitHub Identity for Wiki Commits

| Upstream | This repo |
|---|---|
| Dedicated `GITHUBUSERID_PROD` / `GITHUBTOKEN_PROD` secrets (static PAT) | `github.actor` + built-in `GITHUB_TOKEN` |

> **Note:** `GITHUB_TOKEN` is scoped to the current repository. If the wiki lives in a separate repository (e.g., `bcgov-c/azure-lz-core-forge.wiki.git`), a PAT with `repo` scope will need to be substituted.

### 4. Encryption Removed

| Upstream | This repo |
|---|---|
| `aesEncryptionKey` and `aesEncryptionIV` inputs always passed to `policyDocGenerateWiki` | Inputs are accepted but only forwarded to `New-AzplDocumentation` when both values are non-empty; by default they are unset and encryption is bypassed |

The upstream optionally encrypts discovery artifacts. The action inputs remain for compatibility but are excluded from the PowerShell parameter hashtable unless both `aesEncryptionKey` and `aesEncryptionIV` are supplied.

### 5. Workflow Trigger — No Branch Guards or Schedule

| Upstream | This repo |
|---|---|
| `push` trigger with branch filters; scheduled cron runs twice daily | `workflow_dispatch` only; cron commented out |

The schedule (`30 5,21 * * *`) is present but commented out to avoid unintended runs until the workflow is validated end-to-end.

### 6. Initiation Step — Per-Job Instead of Standalone Job

| Upstream | This repo |
|---|---|
| Separate `job_setVariables` / `job_initiation` job that outputs variables consumed by downstream jobs | `initiation` composite action runs as the first step inside each job |

Running initiation locally in each job avoids passing outputs across job boundaries and simplifies the dependency graph.

### 7. No Separate `setVariables` Action Template

| Upstream | This repo |
|---|---|
| Dedicated `.github/actions/templates/setVariables/` composite action | Variable loading merged into the `initiation` action (`github-set-variables.ps1` is called directly) |

### 8. PowerShell Script Invocation — Bash Wrapper

| Upstream | This repo |
|---|---|
| Steps use `shell: pwsh` directly | Steps use `shell: bash` with `pwsh -File …` to control the working directory and relative module paths |

### 9. Module Import Paths

| Upstream | This repo |
|---|---|
| Modules resolved relative to the repo root | Import paths in `environment-discovery.ps1` and `generate-wiki-pages.ps1` updated to use relative paths from the scripts directory: `../../../ps_modules/…` |

### 10. Configuration Scope

| Upstream sample | This repo |
|---|---|
| `github-config.jsonc` contains multiple sample environments | Single `forge` environment entry targeting `bcgov-managed-lz-forge-platform` management group and the `bcgov-c/azure-lz-core-forge.wiki.git` repository |

---

## Recommended Upstream Maintenance Approach

Use a **curated overlay** model: regularly import upstream improvements from `Azure/AzPolicyLens`, then intentionally re-apply and verify BC Gov-specific behavior documented above.

### Upstream Baseline Registry

Maintain this table as the source of truth for upstream alignment. Add one row for each completed sync.

| Local sync/reference date | Upstream repository | Upstream tag | Upstream commit SHA | Local integration commit | Notes |
|---|---|---|---|---|---|
| 2026-05-08 | `Azure/AzPolicyLens` | _none published_ | `5b829c0064841bfc92b0d44b2758a1bd18b47d87` | `8c97215e9a17d2a46f208a63e90b7c4de439b4df` | Initial BC Gov import of policy documentation workflow/actions/scripts; local overlays applied afterward. |

Update rule:

- When an upstream sync PR is merged, append a new row and keep previous rows for auditability.
- If upstream starts publishing release tags, populate `Upstream tag` and keep SHA for immutability.

### 1. Track an Explicit Upstream Baseline

- For each sync cycle, record the upstream tag or commit SHA used as the baseline.
- Keep that baseline reference in the maintenance PR description so drift is auditable.

### 2. Classify Changes Before Merging

Treat files in two groups:

- **Upstream-following files**: pull upstream changes with minimal local divergence.
- **Local overlay files**: preserve intentional BC Gov behavior (single `forge` environment, OIDC auth model, trigger posture, script/module path conventions, and token handling choices).

### 3. Use a Repeatable Sync Flow

1. Fetch upstream updates into a dedicated sync branch.
2. Diff local vs upstream for the policy documentation workflow, action templates, scripts, and module manifests.
3. Apply upstream updates first.
4. Re-apply local overlays deliberately (do not assume automatic conflict resolution preserves intent).
5. Run validation checks before merging.

### 4. Validate Behavior After Every Sync

Minimum checks:

- Manual run of `Policy Documentation` workflow (enable debug input).
- Discovery artifact is produced and consumed correctly.
- Parse config matrix still resolves expected wiki targets.
- Wiki generation and push logic still matches repository authentication model.

### 5. Keep Local Delta Documentation Current

- When local behavior changes, update the "Differences from Upstream" section in this README in the same PR.
- If a local customization is no longer needed because upstream now supports it, remove the customization and the corresponding delta note.

### 6. Recommended Cadence

- **Routine**: perform upstream sync at least monthly.
- **Fast-track**: sync immediately when upstream releases security-related fixes or major workflow/script changes.

### 7. Conflict Hotspots to Review First

Start review with these files because they are the most likely to require manual overlay reconciliation:

- `.github/workflows/policy-documentation.yml`
- `.github/actions/templates/policyDocDiscovery/action.yml`
- `.github/actions/templates/policyDocGenerateWiki/action.yml`
- `azure_policy_lens/scripts/pipelines/policy-documentation/environment-discovery.ps1`
- `azure_policy_lens/scripts/pipelines/policy-documentation/generate-wiki-pages.ps1`

### 8. AI-Assisted Maintenance Playbook

For AI-specific sync instructions, use `README.maintenance-ai.md` in this directory.

---

## Required Secrets

| Secret | Description |
|---|---|
| `AZURE_CLIENT_ID` | Client ID of the Entra ID app registration used for OIDC |
| `AZURE_TENANT_ID` | Entra ID tenant |
| `AZURE_SUBSCRIPTION_ID` | Subscription used as the login context |

The `GITHUB_TOKEN` secret is provided automatically by GitHub Actions.

---

## Running the Workflow

1. Navigate to **Actions → Policy Documentation** in the repository.
2. Click **Run workflow**.
3. Optionally enable **debug logging**.

The workflow will:
1. Discover all Azure Policy assignments under the `bcgov-managed-lz-forge` management group.
2. Parse `configurations/github-config.jsonc` to determine which wikis to generate.
3. Generate and push wiki pages to the configured Git repository.
