# AI Maintenance Guide for AzPolicyLens Syncs

This guide is for future AI-assisted maintenance of the local AzPolicyLens implementation in this directory.

Primary source documents:

- `azure_policy_lens/README.md`
- `.github/workflows/policy-documentation.yml`
- `.github/actions/templates/policyDocDiscovery/action.yml`
- `.github/actions/templates/policyDocGenerateWiki/action.yml`
- `azure_policy_lens/scripts/pipelines/policy-documentation/environment-discovery.ps1`
- `azure_policy_lens/scripts/pipelines/policy-documentation/generate-wiki-pages.ps1`

## Objective

Keep local implementation aligned with `Azure/AzPolicyLens` while preserving intentional BC Gov overlays.

## Non-Negotiable Local Overlays

Unless explicitly changed by maintainers, preserve these local behaviors during upstream syncs:

1. Single environment scope (`forge`) in workflow orchestration.
2. OIDC-based Azure login (`azure/login@v2` with client/tenant/subscription IDs).
3. Trigger posture centered on `workflow_dispatch` (cron optional/commented until approved).
4. Local script/module path conventions under `azure_policy_lens/`.
5. Current GitHub authentication model and wiki push behavior.

## Local Performance Enhancements To Preserve

The local implementation now includes intentional performance changes. During upstream syncs, preserve these unless maintainers explicitly request rollback.

1. Wiki generation concurrency in `AzPolicyLens.Wiki`:
  - Orchestrator-level concurrent page generation via task runner in `ps_modules/AzPolicyLens.Wiki/AzPolicyLens.Wiki.psm1`.
  - Batched/parallel page writes in `ps_modules/AzPolicyLens.Wiki/AzPolicyLens.Wiki.Pages.Helper.psm1`.
  - `WriteThrottleLimit` support through script/module call chain (`generate-wiki-pages.ps1` -> `New-AzplDocumentation` -> page functions).
2. Environment Discovery concurrency in `AzPolicyLens.Discovery`:
  - Top-level parallel fan-out for policy resources, management-group hierarchy, and subscriptions.
  - Parallel execution of independent assignment-scoped ARG queries (compliance, exemptions, subscription summary, policy-definition-group summary).
3. Timing instrumentation and summaries:
  - Reusable timing helpers in `ps_modules/AzPolicyLens.Wiki/AzPolicyLens.Wiki.Utility.Helper.psm1`.
  - Phase-level timing in wiki pipeline script/module.

## Concurrency Safety Rules

When modifying any concurrent runner or task payload format:

1. Validate each task object before execution:
  - Require non-empty `Name` and `FunctionName`.
  - Normalize null `Parameters` to empty hashtable.
  - Normalize ordered dictionaries to hashtables before splatting.
2. Execute helper functions inside module scope for thread jobs:
  - Do not assume internal/non-exported functions are available in ambient runspace scope.
3. Use bounded concurrency:
  - Keep throttles conservative to reduce ARG/API throttling risk.
4. Keep dependency chains serial:
  - Only parallelize independent branches.
  - Preserve ordering where one query depends on another's result set.

## Known Regression Patterns (Do Not Reintroduce)

1. Output-stream contamination:
  - Avoid `Write-Output` in timing/helper wrappers that return data objects.
  - Use verbose/log streams instead, otherwise callers can receive `System.Object[]` instead of expected hashtables/objects.
2. Invalid module scriptblock argument passing:
  - Do not use unsupported argument patterns that can null out function names in job runspaces.
3. Global collector type drift under parallel runs:
  - When appending to shared collectors, initialize and normalize to array first.
4. GitHub compliance label escaping artifacts:
  - Keep status-label text normalization so escaped characters (slash/operator artifacts) do not render visibly on root wiki pages.

## Wiki Output Validation Checklist (Detailed + Basic)

After any wiki module/script sync or refactor, verify both page styles:

1. Detailed generation succeeds end-to-end.
2. Basic generation succeeds end-to-end.
3. Root page compliance rating text is clean (no visible escape slashes).
4. Syntax-validation summary sections render correctly when there are failures.
5. Timing summary logs do not alter returned object types.

## AI Sync Procedure

1. Identify upstream target baseline.
2. Record candidate upstream SHA (and tag if available) before making changes.
3. Compare local files against upstream equivalents, including `.github/workflows/policy-documentation.yml` and every file under `.github/actions/templates/`.
4. Apply upstream improvements first.
5. Re-apply required local overlays deliberately.
6. Update `azure_policy_lens/README.md`:
   - Append a row in "Upstream Baseline Registry".
   - Update "Differences from Upstream" if behavior changed.
7. Run validation checks (or provide exact commands if execution is not possible).

## Centralized Template Syncs

When upstream changes workflow orchestration or action contracts, treat the workflow and the reusable action templates as one unit:

- Update the local template implementation and all call sites in the same PR.
- If upstream adds or removes a template input, confirm the workflow defaults and script parameters still match.
- For branch-based test runs, point `SHARED_AZPOLICYLENS_REF` at the pushed feature branch, then return it to a release tag or commit SHA after validation.
- Refresh the README differences table if the centralized action-template model or workflow behavior changes.

## Suggested Comparison Map

- Upstream `.github/workflows/policy-documentation.yml`
  -> Local `.github/workflows/policy-documentation.yml`
- Upstream `.github/actions/templates/policyDocDiscovery/action.yml`
  -> Local `.github/actions/templates/policyDocDiscovery/action.yml`
- Upstream `.github/actions/templates/policyDocGenerateWiki/action.yml`
  -> Local `.github/actions/templates/policyDocGenerateWiki/action.yml`
- Upstream `scripts/environment-discovery.ps1`
  -> Local `azure_policy_lens/scripts/pipelines/policy-documentation/environment-discovery.ps1`
- Upstream `scripts/generate-wiki-pages.ps1`
  -> Local `azure_policy_lens/scripts/pipelines/policy-documentation/generate-wiki-pages.ps1`
- Upstream `scripts/github-policy-doc-parse-config-file.ps1`
  -> Local `azure_policy_lens/scripts/pipelines/policy-documentation/github-policy-doc-parse-config-file.ps1`

## PR Output Expectations (AI)

Every AI-generated maintenance PR should include:

1. Upstream baseline metadata:
   - Upstream repo, tag (or none), SHA.
   - Date/time baseline was captured.
2. Change classification:
   - Upstream-adopted changes.
   - Re-applied BC Gov overlays.
3. Risk notes:
   - Potential behavior changes in workflow/auth/wikigen.
4. Validation evidence:
   - Workflow dry-run/manual dispatch result, or explicit blocker.

## Guardrails

- Do not remove local overlays unless maintainers explicitly request it.
- Do not assume conflict resolution preserved behavior; inspect auth, trigger, and script args carefully.
- Prefer small, reviewable commits during large syncs.
- Keep markdown docs in sync with implementation changes in the same PR.
- If a sync touches concurrency/task runners, include explicit notes on task-shape compatibility and module-scope invocation behavior.

## Quick Prompt Template for Future AI Runs

Use this prompt pattern when asking an AI agent to perform a sync:

"Sync local AzPolicyLens implementation with upstream `Azure/AzPolicyLens` at <SHA or tag>. Preserve BC Gov overlays documented in `azure_policy_lens/README.md`. Update workflow/templates/scripts as needed, then append a new row to the Upstream Baseline Registry and refresh Differences from Upstream. Provide a concise validation report for discovery, parse config matrix, and wiki generation behavior."
