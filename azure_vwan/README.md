# azure_vwan

Shared modules for Azure Virtual WAN concerns that sit outside CAF:

| Module | Purpose |
|--------|---------|
| `routing_intent_and_policies` | Hub default route table / routing-intent related routes |
| `route_maps` | Low-level Virtual Hub route maps (filter / summarize BGP advertisements) |
| `routing` | Opinionated outbound ASN-drop map + VPN/ExR `routingConfiguration` attachments |

Callers: `azure-lz-core-forge` / `azure-lz-core-live` under `azure_vwan/`.

Prefer `routing` for the standard on-prem outbound filter. Use `route_maps` only when you need custom map rules without the connection-attachment opinion.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->