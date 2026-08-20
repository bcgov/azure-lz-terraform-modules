# Routing and DNS for isolated expansion VNets

This is the packet-level path for `firewall_snat` (and `private_nat`, which is the same contract with a Linux NVA instead of a spoke Azure Firewall). The [README](README.md) keeps the short mode tables; use this file for how traffic and name resolution actually move.

Workload Internet and DNS do **not** use the management `0.0.0.0/0` → Internet route. That table is only on `AzureFirewallManagementSubnet`. SNATed packets and DNS queries leave `AzureFirewallSubnet` (or the NVA subnet) and follow vWAN routing intent into the hub.

## The three networks

- **Expansion VNet** — isolated CIDR (for example `10.10.0.0/16`). Not on vWAN. Not advertised on-prem. Only knows the spoke via **direct peering**.
- **Routable spoke** — enterprise CIDR, vWAN-connected. Hosts the spoke Azure Firewall (`AzureFirewallSubnet` + `AzureFirewallManagementSubnet`) or the private NAT NVA.
- **vWAN hub** — hub Azure Firewall. Routing intent programs spoke subnets with `0.0.0.0/0` → hub (and RFC1918 via the hub) unless a custom UDR replaces that.

The isolated prefix must never appear in vWAN or ExpressRoute. After SNAT, the enterprise only sees the **spoke firewall or NVA private IP**.

## What each subnet actually has

**Expansion subnets** (module-owned table, BGP off):

- `0.0.0.0/0` → VirtualAppliance → spoke firewall or NVA IP (default `.4` in the hop subnet, or `private_ip`)
- Azure system routes still cover the expansion CIDR and the **peered spoke CIDR**

Longest prefix wins. Traffic to the spoke stays on peering. Everything else, including the hub firewall IP and the Internet, hits `0.0.0.0/0` and goes to the SNAT hop.

**`AzureFirewallSubnet` (data plane)** — no module table by default:

- vWAN routing intent programs `0.0.0.0/0` → hub firewall
- After SNAT, Internet, on-prem, other spokes, and hub DNS all follow that route
- `spoke_route_table_id` is only an override if this spoke already uses a custom UDR

**NVA subnet (`private_nat`)** — same as the firewall data subnet: no module table unless `spoke_route_table_id` is set, so routing intent applies.

**`AzureFirewallManagementSubnet`** — module table, BGP off:

- `0.0.0.0/0` → **Internet**
- Only the firewall’s Azure management/health NIC uses this
- This stops routing intent from sucking the management NIC into the hub, which breaks a forced-tunnel firewall
- It does **not** carry VM or SNAT traffic

Putting `0.0.0.0/0` → Internet on **`AzureFirewallSubnet`** *would* bypass the hub. The module does not do that.

```mermaid
flowchart TB
  vm[Expansion VM]
  expUdr["Expansion UDR 0.0.0.0/0 to spoke hop"]
  spokeCidr[Spoke CIDR via peering]
  data[AzureFirewallSubnet or NVA subnet]
  mgmt[AzureFirewallManagementSubnet]
  hub[Hub firewall]
  inet[Internet]
  onprem[On-prem / other spokes]
  az[Azure management]

  vm --> expUdr
  vm --> spokeCidr
  expUdr -->|"SNAT to spoke hop IP"| data
  data -->|"vWAN RI 0.0.0.0/0"| hub
  hub --> inet
  hub --> onprem
  mgmt -->|"UDR 0.0.0.0/0 Internet"| az
```

## Default outbound access is not the hub path

The module sets `defaultOutboundAccess = false` on the firewall, NVA, and resolver subnets it creates. Expansion subnets default to the same. That only removes Azure’s implicit public SNAT.

It does **not** remove vWAN routing-intent routes. After SNAT, Internet and on-prem still use the data-plane subnet’s effective routes (`0.0.0.0/0` → hub).

A spoke with “no default outbound” is the normal landing-zone spoke. Turning default outbound back on would not fix a missing hub path, and would send Internet the wrong way.

If the spoke has **no routing intent and no `spoke_route_table_id`**, the data-plane subnet has no `0.0.0.0/0` at all. SNATed Internet, on-prem, and DNS to the hub firewall then blackhole. That is a spoke-connection problem, not something default outbound would have fixed.

## Packet walks (`firewall_snat`)

Assume:

- Expansion VM = `10.10.0.10`
- Spoke = `10.40.32.0/21`
- Spoke firewall = `10.40.32.68`
- Hub firewall DNS proxy = `<hub-firewall-dns-proxy-ip>`

`private_nat` is the same walks with the NVA IP as the hop.

### Expansion → something in the spoke (app, private endpoint)

Default `direct_peer_bypass = true`.

1. Destination is inside the peered spoke prefix.
2. Azure’s peering route is more specific than `0.0.0.0/0`.
3. Packet goes **straight across peering**. Source stays `10.10.0.10`. No SNAT.

The spoke must allow that isolated source on NSGs. The hub never sees this flow.

Setting `direct_peer_bypass = false` steers even the spoke CIDR through the hop so the expansion prefix can be hidden from the peer.

### Expansion → Internet (or on-prem, or another spoke)

1. Destination is not in the expansion VNet and not in the peered spoke CIDR.
2. Expansion UDR: next hop = spoke firewall IP.
3. Packet arrives on the spoke firewall **data** NIC: `src=10.10.0.10`, original destination.
4. Spoke policy allows expansion CIDR → `*`.
5. Forced-tunnel SNAT (`private_ip_ranges = ["255.255.255.255/32"]`) translates RFC1918 too. Source becomes the spoke firewall IP.
6. Firewall looks up **`AzureFirewallSubnet`** routes, not the management table. Next hop is the hub (routing intent).
7. Hub firewall sees a normal **spoke** source, inspects, then forwards to Internet / on-prem / other spokes.
8. Return hits the spoke firewall IP. The spoke firewall un-SNATs to `10.10.0.10` and sends it back over peering (`allow_forwarded_traffic`).

vWAN and on-prem never learn `10.10.0.0/16`.

### Firewall platform traffic (not your workload)

The management NIC needs Azure. Routing intent would otherwise give it `0.0.0.0/0` → hub and break forced tunnel. The module-owned management UDR sends that NIC to Internet. VMs never use this path.

## How DNS works on the expansion VNet

For `firewall_snat` and `private_nat`, the expansion VNet’s **custom DNS servers** are `hub_firewall_dns_servers` (the hub firewall DNS proxy). The VM does not use Azure-provided `168.63.129.16` unless you opt into a spoke resolver, `dns.mode = custom`, or (for `none` / `nat`) a platform forwarding ruleset.

A query for `privatelink.blob.core.windows.net` (or anything else):

1. Azure DHCP on the expansion NIC says DNS = hub firewall IP.
2. VM sends `UDP/53` to that hub IP.
3. The hub IP is **not** in the peered spoke CIDR, so the expansion UDR applies: next hop = spoke firewall (or NVA).
4. The hop SNATs: `src=<spoke-hop-ip>`, `dst=<hub-firewall-dns-proxy-ip>:53`.
5. The data-plane subnet sends that to the hub via routing intent.
6. Hub DNS proxy answers from a **spoke** source it already knows. It forwards to the central Private DNS Resolver inbound (the same path normal spokes use). That inbound’s VNet is linked to the privatelink zones.
7. Reply reverses: hub → spoke hop → un-SNAT → peering → VM.

```mermaid
sequenceDiagram
  participant VM as Expansion VM
  participant ExpUDR as Expansion 0.0.0.0/0
  participant SpokeHop as Spoke firewall or NVA
  participant HubFW as Hub firewall DNS proxy
  participant Resolver as Central resolver inbound

  VM->>ExpUDR: UDP/53 to hub FW IP
  ExpUDR->>SpokeHop: next hop spoke hop
  Note over SpokeHop: SNAT src to spoke hop IP
  SpokeHop->>HubFW: UDP/53 via vWAN RI
  HubFW->>Resolver: same as any spoke
  Resolver-->>HubFW: answer
  HubFW-->>SpokeHop: reply
  Note over SpokeHop: un-SNAT to expansion IP
  SpokeHop-->>VM: via peering
```

The spoke Basic firewall is **not** a DNS proxy. It only forwards UDP/53 after SNAT. Hub policy must already allow DNS from the **spoke hop IP** (a spoke address). Do not add the isolated CIDR to hub or vWAN routes.

### DNS server priority

1. `spoke_dns_resolver` inbound (explicit opt-in)
2. `dns.mode = custom` + `dns.servers`
3. `hub_firewall_dns_servers` when mode is `firewall_snat` or `private_nat`
4. Azure-provided DNS (`none` / `nat`)

`none` and `nat` cannot reach the hub proxy. Prefer `dns_forwarding_ruleset_id` from the central resolver's isolated-expansion ruleset (`azure_private_dns/private_dns_resolver`). That ruleset is `.` → inbound; Azure-provided DNS performs the hop so the VM never opens a socket to the inbound. Do not link privatelink zones to every expansion VNet and do not enable `spoke_dns_resolver` unless that ruleset is unavailable. See the [README private DNS section](README.md#private-dns-resolution).

## Still not this module

- Hub firewall **policy** must already allow the spoke firewall or NVA SNAT IP (UDP/53 and whatever else the workload needs). Isolated expansion CIDRs must not be added to hub or vWAN routes.
- Caller still supplies unused spoke prefixes (`/26`s for the firewall, `/28` for the NVA) and any landing-zone policy exemption to create Azure Firewall in an application subscription.
- `spoke_route_table_id` remains an override when a spoke already uses a custom UDR. Leave it unset on a routing-intent spoke.
