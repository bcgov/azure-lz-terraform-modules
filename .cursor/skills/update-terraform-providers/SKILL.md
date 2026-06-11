---
name: update-terraform-providers
description: Review and update Terraform provider constraints for the Azure landing zone module repo. Use when bumping azurerm, azapi, azuread, alz, modtm, random, null, assert, azureipam, fabric, or Terraform required_version constraints in azure-lz-terraform-modules.
---

# Update Terraform Providers

## Scope

Use this skill in `azure-lz-terraform-modules` when reviewing or changing Terraform provider constraints.

This workflow must work in a greenfield environment. Do not assume the repo is already checked out in a specific local path.

Use the GitHub CLI for repository operations:

```bash
gh auth status
export LZ_WORKDIR="${LZ_WORKDIR:-$(mktemp -d /tmp/lz-provider-work.XXXXXX)}"
gh repo clone bcgov/azure-lz-terraform-modules "$LZ_WORKDIR/azure-lz-terraform-modules"
export MODULES_REPO="$LZ_WORKDIR/azure-lz-terraform-modules"
```

If the repo is already present, set `MODULES_REPO` to that path instead of cloning again. If cloning is needed, clone under `/tmp` and remove `LZ_WORKDIR` after the operation is complete. If `gh auth status` fails, stop and ask the user to authenticate.

Typical files:

- `**/provider.tf`
- `**/providers.tf`
- `**/versions.tf`
- root consumer modules such as `terraform-azure-lz-project-set/main.tf`
- CAF composition files under `caf_cccs_medium/`

Do not update `bcgov-c/azure-lz-vending-forge`, `bcgov/azure-lz-vending-live`, `bcgov-c/azure-lz-core-forge`, or `bcgov/azure-lz-core-live` provider pins as part of this skill unless the user explicitly asks for the rollout or test PRs. If rollout is requested, clone those repos with `gh repo clone` into the `/tmp` `LZ_WORKDIR` and create PRs with `gh pr create`.

Provider-only changes in this repo often need real plans in sibling live/forge repos. Prefer existing local checkouts when present:

```bash
export CORE_FORGE="${CORE_FORGE:-../azure-lz-core-forge}"
export VENDING_FORGE="${VENDING_FORGE:-../azure-lz-vending-forge}"
export VENDING_LIVE="${VENDING_LIVE:-../azure-lz-vending-live}"
```

## Current Policy

Reusable modules should use flexible constraints:

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}
```

Prefer `~>` constraints over exact pins for reusable modules.

Keep exact pins only when there is a documented compatibility reason.

## Known Providers

Check latest versions from the Terraform Registry before editing:

```bash
for p in \
  hashicorp/azurerm \
  azure/azapi \
  hashicorp/azuread \
  azure/alz \
  azure/modtm \
  hashicorp/random \
  hashicorp/null \
  hashicorp/assert \
  XtratusCloud/azureipam \
  microsoft/fabric
do
  curl -sS "https://registry.terraform.io/v1/providers/$p" \
    | python3 -c 'import json,sys; d=json.load(sys.stdin); print("'"$p"'", "->", d.get("version"))'
done
```

Expected constraint families:

- `hashicorp/azurerm`: latest 4.x minor as `~> 4.<latest-minor>`
- `azure/azapi`: latest 2.x minor as `~> 2.<latest-minor>`
- `hashicorp/azuread`: latest 3.x minor as `~> 3.<latest-minor>`
- `azure/alz`: latest 0.x minor as `~> 0.<latest-minor>`
- `azure/modtm`: `~> 0.3`
- `hashicorp/random`: `~> 3.6`
- `hashicorp/null`: `~> 3.2`
- `hashicorp/assert`: `~> 0.16`
- `XtratusCloud/azureipam`: latest major approved by the user; treat 1.x to 2.x as breaking until planned
- `microsoft/fabric`: latest 1.x minor as `~> 1.<latest-minor>`

Do not blindly force a provider to the registry's latest minor when a child module constrains it lower. Example: `azure_network_watcher/network_connection_monitor` calls `Azure/avm-res-network-networkwatcher/azurerm`, which constrains `azure/modtm` to `~> 0.3.0`; keep `modtm` at `~> 0.3` there until the child module supports 0.4.

## CAF Exception

Be careful with `caf_cccs_medium/`.

`Azure/caf-enterprise-scale/azurerm` v6.3.1 is tied to older provider expectations. Do not force `caf_cccs_medium` and its internal CAF wrapper modules from azurerm 3.x to azurerm 4.x unless the user explicitly approves a larger CAF module upgrade.

`caf_cccs_medium` must remain self-contained: modules inside this repo should use local relative sources such as `../azure_key_vault/key_vault`, not `git::https://github.com/bcgov/azure-lz-terraform-modules.git//...?ref=...`. If a provider update introduces same-repo git sources, replace them with local paths and validate through `azure-lz-core-forge/caf`.

When CAF itself is out of scope, leave these provider pins unchanged:

- `caf_cccs_medium/main.tf`
- `caf_cccs_medium/modules/core/main.tf`
- `caf_cccs_medium/modules/connectivity/main.tf`
- `caf_cccs_medium/modules/management/main.tf`

Child modules consumed by `caf_cccs_medium` may need a wider AzureRM range, such as `>= 3.112.0, < 5.0.0`, so CAF can use AzureRM 3.116 while non-CAF roots can still select AzureRM 4.x. Do not narrow those back to `~> 4.x` without checking the CAF root plan.

Also preserve comments that warn a submodule cannot be called from CAF when it requires azapi v2.

## Review Workflow

1. Inventory provider declarations:

```bash
cd "$MODULES_REPO"
rg 'required_providers|required_version|source\s*=|version\s*=' -g '*.tf'
```

2. Find provider config files:

```bash
rg --files -g 'provider.tf' -g 'providers.tf' -g 'versions.tf'
```

3. Check resources in modules that have provider config but no `required_providers` block:

```bash
rg '^(resource|data|provider)\s+"' <module>
```

4. Add missing declarations for providers actually used by the module.
5. Keep provider configuration blocks intact, especially `subscription_id`, aliases, `use_oidc`, `features {}`, and `skip_provider_registration`.

## Determine Real Plan Roots

Do not run real plans against every directory with a `backend.tf`. Classify roots first.

Use multiple signals:

```bash
cd "$CORE_FORGE"
rg 'terraform\s+(init|plan|apply)|pushd ' .github/workflows -g '*.yml' -g '*.yaml'
rg '^(module|resource|data|provider|terraform|import|moved)\s+"?' -g '*.tf'
rg 'source\s*=\s*"git::https://github.com/bcgov/azure-lz-terraform-modules.git//' -g '*.tf'
rg --files -g 'backend.tf' -g '*.auto.tfvars' -g '.terraform.lock.hcl'
```

Treat a root as top-level when it has active `module` or `resource` blocks plus backend/tfvars/workflow/state evidence. Exclude roots with only scaffolding or commented module calls. In `azure-lz-core-forge`, `azure_express_route/express_route_connection` has backend/tfvars but its module call is commented out and outputs still reference an undeclared module; do not include it as an active plan root unless it is re-enabled.

Known active `azure-lz-core-forge` top-level roots:

- CI-backed: `caf`, `azure_private_dns`, `azure_network_watcher/network_connection_monitor`, `azure_vwan/routing_intent_and_policies`, `azure_monitor_baseline_alerts`, `azure_firewall/base_policy`, `azure_firewall/base_policy_rules`
- Stateful/manual roots with active config: `azure_vpn/site_and_connection`, `azure_express_route/express_route_circuit`, `azure_express_route/express_route_peering`, `azure_express_route/traffic_collector`, `azure_logic_app`
- Not active: `azure_express_route/express_route_connection`

`caf` only calls `caf_cccs_medium`; it is not the parent for the separate roots above.

If `terraform-azure-lz-project-set` or `azure_ad_groups` changes, plan active `projects/*` roots in `azure-lz-vending-forge` and `azure-lz-vending-live`, because those modules are consumed by each project root. Do not plan the reusable module directories directly as a substitute.

## Compatibility Checklist

Before accepting a major bump:

- For `azurerm` 3.x to 4.x, confirm `subscription_id` is provided in provider config or by `ARM_SUBSCRIPTION_ID`.
- For `azapi` 1.x to 2.x, inspect `azapi_resource`, `azapi_update_resource`, and `azapi_resource_action` bodies for v2 schema expectations.
- For `azuread` 2.x to 3.x, inspect `azuread_*` resources and data sources. If IDs are stored in state or `null_resource` triggers, prefer stable `object_id` values over provider `id` values because AzureAD v3 can return path-style IDs such as `/groups/<uuid>`.
- For `azureipam` 1.x to 2.x, treat as breaking until tested against the live IPAM service.
- Do not update generated README provider tables by hand unless the repo already uses a docs generation workflow for that module.

## Editing Rules

Use the repo's preferred style:

- `required_version = ">= 1.9, < 2.0"`
- `version = "~> 4.0"`, not `version = "~>4.0"`
- Declare providers in `required_providers` when resources or data sources use them.
- Keep provider aliases and operational comments.
- Do not mix broad refactors with provider updates.

## Validation

Always run:

```bash
cd "$MODULES_REPO"
terraform fmt -recursive
terraform fmt -check -recursive
```

For changed standalone modules, run backend-disabled validation first:

```bash
cd <module>
terraform init -backend=false -input=false -upgrade
terraform validate
```

Then run real plans from true top-level roots, not from leaf module directories.

### Core Forge Local-Source Plans

`azure-lz-core-forge` has a helper for local module source testing. Use it instead of hand-editing every `source` line:

```bash
cd "$CORE_FORGE"
python3 scripts/local_module_sources.py enable azure_private_dns
terraform -chdir=azure_private_dns init -upgrade -reconfigure
terraform -chdir=azure_private_dns validate
terraform -chdir=azure_private_dns plan -detailed-exitcode
python3 scripts/local_module_sources.py disable azure_private_dns
```

Without root arguments, `enable` and `disable` apply to every root that references `bcgov/azure-lz-terraform-modules`. Generated `local_modules_override.tf` files are temporary and should be ignored/removed before finishing.

For real backend plans in forge, ensure the backend can find the state storage account in the forge management subscription. If backend blocks lack it, use or add it in the private consumer repo only; do not commit real subscription IDs to this public modules repo:

```hcl
subscription_id = "<forge-management-subscription-id>"
```

Also set the Azure CLI or environment to the intended deployment subscription before planning. A wrong default subscription can produce false-positive changes in provider data lookups.

### Vending Forge and Live Plans

When `terraform-azure-lz-project-set` or `azure_ad_groups` changes, identify active project roots in `azure-lz-vending-forge/projects/*` and `azure-lz-vending-live/projects/*` and plan those roots. The workflows plan changed projects, and a `config.json` change causes all projects to run:

```bash
cd "$VENDING_FORGE"
rg 'module "(project_set|azure_ad_groups)"|terraform plan|cd "projects/' -g '*.tf' -g '*.yaml'

cd "$VENDING_LIVE"
rg 'module "(project_set|azure_ad_groups)"|terraform plan|cd "projects/' -g '*.tf' -g '*.yaml'
```

For forge projects, active roots have historically been `projects/abc123` and `projects/e833c2`; confirm with `rg` and workflows rather than assuming. Do not update `projects-to-close` or `projects-closed` unless the user explicitly asks for closeout/destroy validation.

If project roots point at a module branch or new release that updates provider constraints, align the root provider constraints too. For example, an `azure_ad_groups` update to AzureAD v3 requires the root to move from `azuread = "2.x"` to a compatible `~> 3.x` constraint.

For real backend plans in vending forge, ensure the backend can find the state storage account in the forge management subscription. Use a placeholder in public docs and commit the real value only in private consumer repos:

```hcl
subscription_id = "<forge-management-subscription-id>"
```

Vending project plans can require `Microsoft.Subscription/aliases/write` or equivalent subscription alias permissions even for reads. If local plans fail with `401 UserNotAuthorized` on `/providers/Microsoft.Subscription/aliases/<project-env>`, report the blocker and include any partial plan summary; CI/service principals may have the required permission.

If many projects are affected, sample only with explicit user approval; otherwise report that all project roots need CI or batch local plans.

If validation or real plans cannot complete because of network, backend, Azure credentials, provider registry limits, or permissions, report that plainly and include which roots were not validated.

## GitHub Actions

Use `gh` for PRs and workflow inspection:

```bash
gh pr create --repo bcgov/azure-lz-terraform-modules --title "Update Terraform provider constraints" --body-file <body-file>
gh pr status --repo bcgov/azure-lz-terraform-modules
gh run list --repo bcgov/azure-lz-terraform-modules --limit 20
gh run view <run-id> --repo bcgov/azure-lz-terraform-modules --log-failed
```

## Review Output

When done, summarize:

- Latest provider versions checked.
- Provider constraints changed.
- Real top-level roots identified and any roots intentionally excluded.
- CAF or other exceptions intentionally left pinned.
- Validation commands run and their results.
- Real plan results: no-change roots, in-place changes, create/destroy/replacement risks, and failures.
- Any affected consumer repo roots still needing CI or batch local plans.

## Cleanup

If temporary clones were created for the workflow, remove them after PRs are created or the investigation is complete:

```bash
rm -rf "$LZ_WORKDIR"
```
