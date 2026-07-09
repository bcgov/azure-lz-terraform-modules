# azure_vwan

Shared modules for Azure Virtual WAN concerns that sit outside CAF:

| Module | Purpose |
|--------|---------|
| `routing_intent_and_policies` | Hub default route table / routing-intent related routes |
| `route_maps` | Virtual hub route maps (filter / summarize BGP advertisements) |

Callers: `azure-lz-core-forge` / `azure-lz-core-live` under `azure_vwan/`.
Route-map **attachment** to VPN/ExR connections is owned by the env `azure_vwan/routing` stack (azapi), not this module.
