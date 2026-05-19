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

## Quick Prompt Template for Future AI Runs

Use this prompt pattern when asking an AI agent to perform a sync:

"Sync local AzPolicyLens implementation with upstream `Azure/AzPolicyLens` at <SHA or tag>. Preserve BC Gov overlays documented in `azure_policy_lens/README.md`. Update workflow/templates/scripts as needed, then append a new row to the Upstream Baseline Registry and refresh Differences from Upstream. Provide a concise validation report for discovery, parse config matrix, and wiki generation behavior."
