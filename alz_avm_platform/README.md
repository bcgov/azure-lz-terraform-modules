# ALZ AVM Platform (Greenfield)

This module creates a greenfield Azure Landing Zone platform baseline using Azure Verified Modules (AVM), with a dedicated Security subscription and Security management group.

## Design goals

- AVM-first composition for management groups/policy, management resources, and Virtual WAN connectivity.
- Greenfield platform topology with dedicated platform subscriptions: management, connectivity, identity, security.
- Component reference parity from existing CAF implementation for selected capabilities:
  - Virtual WAN
  - Azure Firewall in Virtual WAN hubs
  - Private DNS zones and links
- Built-in ALZ policy baseline first, with extension points for later customizations.

## Implemented in v1

- AVM ALZ core module composition with custom architecture including Security management group.
- AVM ALZ management resources in dedicated management subscription.
- AVM ALZ connectivity Virtual WAN composition in dedicated connectivity subscription.
- ExpressRoute and S2S VPN (IPSec) support for Virtual WAN hubs through first-class module inputs.
- Centralized logging default for hub firewall policy insights to the Management subscription Log Analytics workspace.
- Optional AMBA resource deployment in management subscription, scoped to the `platform` management group branch (not workload landing zones).
- Optional identity/security bootstrap resource groups to anchor dedicated platform subscriptions.
- Configurable management group IDs via `management_group_names` for subscription placement and AMBA platform-branch targeting.
- Custom architecture profile excludes `corp`, `online`, and `sandbox` management groups.

## Stubs and placeholders

- Fine-grained policy overrides are accepted through pass-through variables.
- AMBA policy defaults are seeded with safe placeholders where organization-specific values are unknown.
- Deeper security workload bootstrap in security subscription is intentionally left for phase 2.

## Management Group Naming

- Use `management_group_names` to set IDs used by placement logic (`root`, `platform`, `management`, `connectivity`, `identity`, `security`, `landingzones`).
- If you change any IDs from defaults, create or update a matching architecture file under `./lib` and set `architecture_name` to that file's architecture name.
- The shipped `alz_custom` architecture includes `landingzones` but intentionally excludes `corp`, `online`, and `sandbox`.

## Usage

See examples under examples/greenfield-vwan.

## Connectivity Extensions

- Set `enable_express_route = true` to enable ExpressRoute gateway resources on configured hubs.
- Set `enable_s2s_vpn = true` to enable S2S VPN gateway resources on configured hubs.
- Set `external_base_firewall_policy_id` to enforce inheritance from an externally managed base firewall policy across hub firewall policies.
- Provide `express_route_circuit_connections_by_hub` to attach ER circuits to specific hubs.
- Provide `vpn_sites_by_hub` and `vpn_site_connections_by_hub` for IPSec S2S site definitions and connections.
- Provide `routing_intents_by_hub` to layer routing intents per hub without inlining them in `virtual_hubs`.
- Provide `private_dns_zones_by_hub` and `private_dns_resolver_by_hub` to apply hub-specific private DNS zone and resolver overrides during migration.

## Centralized Logging

- `enable_centralized_logging` defaults to `true`.
- When enabled, each hub's `firewall_policy.insights.default_log_analytics_workspace_id` defaults to the Log Analytics workspace created in the Management subscription.
- You can still override hub-level `firewall_policy` values in `virtual_hubs`.

## Custom Policy Support (AVM + ALZ)

Yes. The AVM ALZ stack supports policy customization and assignment workflows.

- `avm-ptn-alz` supports policy value and assignment customization through module inputs such as `policy_default_values` and `policy_assignments_to_modify`.
- The `alz` provider supports custom ALZ library content through `library_references`, and this module already loads `./lib` for custom architecture/policy assets.
- Additional custom policy library references can be passed through `custom_alz_library_references`.

Recommendation for AVM-CAF:

- Include an optional policy-extension sub-module/pattern as part of this AVM-CAF stack for organization guardrails that are platform baseline concerns.
- Keep policy content versioned in-repo (for example under `./lib`) and drive rollout with explicit version references.
- Treat workload/team-specific policy exceptions and rapid-change policy experiments as separate overlays, not baseline.
- See `examples/greenfield-vwan/terraform.tfvars.example` for `policy_default_values` examples and `examples/greenfield-vwan/locals.tf` for `policy_assignments_to_modify` examples.

Future-proofing guidance:

- Prefer a stable baseline policy profile in AVM-CAF, then layer environment-specific overrides through `policy_default_values` and `policy_assignments_to_modify`.
- Keep custom policy definitions and initiatives decoupled from workload repos to avoid drift and circular dependencies.

## Private DNS Spoke/Resolver Support

Yes. AVM connectivity virtual-wan supports private DNS zone and private DNS resolver constructs, and this module already exposes migration-friendly inputs:

- `private_dns_zones_by_hub`
- `private_dns_resolver_by_hub`
- `private_dns_enable_internet_fallback` (defaults to `true`, wiring `NxDomainRedirect`)
- `private_dns_resolver_virtual_network_resource_id_by_hub` (default resolver VNet link map)

Default behavior in this module:

- Private DNS zone links default to internet fallback (`NxDomainRedirect`) when `private_dns_enable_internet_fallback = true`.
- When `private_dns_resolver_virtual_network_resource_id_by_hub` is supplied, private DNS zones include a default virtual network link to the resolver VNet for that hub.

Recommendation for AVM-CAF:

- Include private DNS resolver/zone support in the AVM-CAF platform module as an optional baseline capability.
- Keep it enabled by profile when the platform owns shared DNS and hub-spoke name resolution.
- Keep a separate DNS stack only when there is a hard operational boundary (for example, independent DNS lifecycle, dedicated DNS platform team, or non-standard resolver topology not suitable for the shared hub baseline).

## Keep Separate From AVM-CAF (and Why)

The following should generally remain separate stacks from the AVM-CAF baseline:

- ExpressRoute circuit/peering/provider-side onboarding.
Reason: Carrier coordination, long lead times, and external approval workflows differ from platform baseline cadence.

- Site-to-site VPN partner onboarding and connection changes.
Reason: Frequent partner-specific updates and operational ownership are usually network-operations concerns.

- High-churn firewall rule catalogs and team-owned IP groups.
Reason: Application/team policy changes occur much faster than platform baseline releases and should be delegated.

- Post-deploy vWAN routing intent experiments or one-off azapi updates.
Reason: These are often iterative operational changes and can require controlled rollout/rollback outside baseline provisioning.

- Workload- or product-specific private DNS exceptions.
Reason: Service onboarding exceptions can be frequent and should not destabilize shared platform DNS baseline.

- Optional operations add-ons with separate ownership (for example specialized monitoring packs beyond baseline).
Reason: Different lifecycle, approval path, and blast radius than core platform provisioning.
