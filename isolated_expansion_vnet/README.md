# isolated_expansion_vnet

Provide Azure workloads with additional private RFC1918 address space **without consuming centrally managed enterprise-routable address space**.

The expansion VNet:

- is not connected to Azure Virtual WAN
- is not propagated into enterprise routing
- is not advertised to ExpressRoute, VPN, or on-premises networks
- is directly peered to the workload landing zone's existing routable VNet
- can consume resources and private endpoints in that routable VNet
- can host workloads that need large private address ranges
- supports either NAT Gateway egress or firewall-based private SNAT

The isolated CIDR is usable inside Azure but does not become part of the enterprise routing domain.

Typical consumers include large compute clusters, AKS and other container platforms, data and analytics platforms, CI/CD runners, AI/ML compute, batch processing, and VNet-injected managed services.

This module owns the network pattern only. Workload-specific networking (AKS, Databricks, runners, and similar) belongs in wrapper modules.

## Architecture

```text
                         Enterprise / On-prem
                                 |
                          ExpressRoute / VPN
                                 |
                           Azure vWAN Hub
                                 |
                  +-----------------------------+
                  | Routable Workload VNet      |
                  | Enterprise-managed CIDR     |
                  | Apps / Private Endpoints    |
                  +-------------+---------------+
                                |
                         Direct VNet Peering
                                |
                  +-------------+---------------+
                  | Isolated Expansion VNet     |
                  | Large RFC1918 CIDR          |
                  | NOT connected to vWAN       |
                  | NOT enterprise-routed       |
                  +-------------+---------------+
                                |
                    +-----------+-----------+
                    |                       |
                NAT Mode              Firewall SNAT
```

## Addressing

The existing workload VNet keeps its centrally allocated enterprise-routable prefix. The expansion VNet uses a separate RFC1918 pool reserved for isolated / local Azure use. The module default is `10.10.0.0/16`.

Example:

```text
Routable workload VNet    10.40.32.0/21
Expansion VNet            10.10.0.0/16
```

The expansion range must not overlap the routable VNet, another directly peered VNet, or destinations the expansion workload must reach without SNAT. It must not be propagated to vWAN or advertised over ExpressRoute or VPN.

The same isolated prefix may be reused elsewhere only when those networks can never become directly connected or mutually routable. That reuse policy belongs in platform IPAM, not in this module.

## Egress modes

`none` is the default. Use it when the workload must stay on private paths only: the expansion VNet itself, the directly peered routable VNet, and Private Endpoints reachable over that peering or in the expansion VNet. The module does not create a NAT Gateway and installs a `0.0.0.0/0 -> None` blackhole plus an Internet-deny NSG rule. If residual Databricks-owned endpoints still need a public or enterprise path, use `firewall_snat` instead of claiming a no-egress VNet.

`nat` is for workloads that only need resources in the directly peered workload VNet, private endpoints in that VNet, and public outbound connectivity.

`firewall_snat` is for workloads that must reach on-premises, other landing zones, shared central services, or other vWAN-connected networks while keeping the isolated prefix out of enterprise routing. The firewall is the routing-domain boundary and must SNAT isolated sources to an enterprise-routable IP **before** packets enter vWAN.

Do not attach the expansion VNet to vWAN and rely on a central hub firewall. That would require vWAN to learn the isolated prefix.

### NAT mode traffic

| Flow | Result |
| --- | --- |
| Expansion → routable VNet / private endpoints | Direct peering, original source IP, no NAT |
| Expansion → Internet | NAT Gateway public IP |
| Expansion → other vWAN spokes or on-prem | Not supported |
| On-prem → expansion | Not supported |

NAT mode does not create a `0.0.0.0/0` virtual appliance route. Internet egress is provided by subnet NAT Gateway association.

### Firewall SNAT mode traffic

| Flow | Result |
| --- | --- |
| Expansion → routable VNet (default `direct_peer_bypass = true`) | Direct peering, original source IP |
| Expansion → enterprise prefixes | Firewall private SNAT; destination sees the firewall IP |
| Expansion → Internet (`route_internet_through_firewall = true`) | Firewall Internet SNAT |
| Enterprise / on-prem → expansion CIDR | Not required and must not be configured |

This module uses an **existing** firewall only. It does not create a firewall or modify shared firewall policy. Consume `required_firewall_routes`, `required_firewall_rules`, and `required_private_snat` from a platform networking layer that owns those policy objects.

Setting `direct_peer_bypass = false` steers even the routable VNet CIDR through the firewall so the expansion prefix can be hidden from the peer. That is supported but is not the default.

### None mode traffic

| Flow | Result |
| --- | --- |
| Expansion → routable VNet / customer Private Endpoints | Direct peering, original source IP |
| Expansion → local Private Endpoints (for example `databricks_ui_api`) | VNet local |
| Expansion → Internet | Dropped |
| Expansion → other vWAN spokes or on-prem | Not supported |
| On-prem → expansion | Not supported |

None mode is the intended Databricks classic compute-plane pattern when customer Storage, Key Vault, Event Hubs, and similar Private Endpoints live in the routable VNet, and the Databricks control-plane PE lives in a dedicated subnet in the expansion VNet. Databricks-owned artifact storage, log storage, platform Event Hubs, and metastore endpoints are not necessarily resources you can attach your own Private Endpoints to. Validate those residual dependencies before treating Internet egress as unnecessary.

## Decision rule

```text
Need only local VNet, direct peering, and Private Endpoints,
with Internet explicitly blocked?
  → egress.mode = "none"   (default)

Need public egress as well, but only to the peered VNet
and its private endpoints?
  → egress.mode = "nat"

Need on-prem, other spokes, or residual platform endpoints
without advertising the isolated CIDR?
  → egress.mode = "firewall_snat"
```

## Usage

### NAT Gateway

```hcl
module "compute_expansion" {
  source = "../../isolated_expansion_vnet"

  name                = "compute-isolated-expansion"
  location            = "canadacentral"
  resource_group_name = "<resource-group-name>"

  address_space = ["10.10.0.0/16"]

  routable_vnet = {
    id                  = module.workload_vnet.resource_id
    name                = module.workload_vnet.name
    resource_group_name = module.workload_vnet.resource_group_name
    address_space       = module.workload_vnet.address_space
  }

  subnets = {
    compute = {
      address_prefix = "10.10.0.0/20"
    }

    workers = {
      address_prefix = "10.10.16.0/20"
    }
  }

  egress = {
    mode = "nat"

    nat = {
      public_ip_count = 1
    }
  }

  private_dns_zone_ids = var.private_dns_zone_ids
}
```

### Firewall SNAT

```hcl
module "compute_expansion" {
  source = "../../isolated_expansion_vnet"

  name                = "compute-isolated-expansion"
  location            = "canadacentral"
  resource_group_name = "<resource-group-name>"

  address_space = ["10.10.0.0/16"]

  routable_vnet = {
    id                  = module.workload_vnet.resource_id
    name                = module.workload_vnet.name
    resource_group_name = module.workload_vnet.resource_group_name
    address_space       = module.workload_vnet.address_space
  }

  subnets = {
    compute = {
      address_prefix = "10.10.0.0/20"
    }
  }

  egress = {
    mode = "firewall_snat"

    firewall = {
      firewall_id         = var.firewall_id
      firewall_private_ip = var.firewall_private_ip
      direct_peer_bypass  = true
    }
  }

  enterprise_routes = [
    "10.0.0.0/8",
    "142.0.0.0/8"
  ]

  private_dns_zone_ids = var.private_dns_zone_ids
}
```

### No Internet egress

```hcl
module "databricks_expansion" {
  source = "../../isolated_expansion_vnet"

  name                = "databricks-isolated-expansion"
  location            = "canadacentral"
  resource_group_name = "<resource-group-name>"

  routable_vnet = {
    id                  = module.workload_vnet.resource_id
    name                = module.workload_vnet.name
    resource_group_name = module.workload_vnet.resource_group_name
    address_space       = module.workload_vnet.address_space
  }

  subnets = {
    databricks_public = {
      address_prefix = "10.10.0.0/22"

      delegation = {
        service_name = "Microsoft.Databricks/workspaces"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
        ]
      }
    }

    databricks_private = {
      address_prefix = "10.10.4.0/22"

      delegation = {
        service_name = "Microsoft.Databricks/workspaces"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
        ]
      }
    }

    private_endpoints = {
      address_prefix = "10.10.8.0/26"
    }
  }

  egress = {
    mode = "none"
  }

  private_dns_zone_ids = var.private_dns_zone_ids
}
```

Place customer Storage, Key Vault, SQL, and application Private Endpoints in the routable workload VNet. Place the Databricks `databricks_ui_api` Private Endpoint in the expansion VNet `private_endpoints` subnet. This module does not create those endpoints.

## What this module does not own

- the existing routable workload VNet
- vWAN, ExpressRoute, or VPN
- central DNS zone resources (it only creates VNet links when zone IDs are supplied)
- private endpoints (prefer placing them in the routable VNet)
- workloads deployed into the expansion VNet
- shared enterprise firewall policy

Private endpoints may be created in the expansion VNet, but those isolated addresses (for example `10.10.x.x`) are reachable only from networks that know the isolated prefix: the expansion VNet itself and the directly peered routable VNet.

## DNS

`dns.mode = "azure"` uses Azure-provided DNS. `dns.mode = "custom"` sets VNet DNS servers.

If those resolvers live in the directly peered routable VNet, NAT mode can reach them. If they live elsewhere in the enterprise, use `firewall_snat`.

Private DNS zone IDs are linked to the expansion VNet. Set `link_private_dns_to_routable_vnet = true` only when the routable VNet is not already linked to those central zones.

## NSGs and security

Each subnet gets an NSG unless you pass an existing `nsg_id`. Baseline rules allow Azure Load Balancer inbound and VNet outbound, and deny Internet inbound. NAT and firewall modes also allow Internet outbound. `none` denies Internet outbound. Firewall mode also allows outbound to `enterprise_routes`.

Do not treat the expansion CIDR as trusted merely because it is peered. Scope access on the routable side (for example TCP 443 from a specific expansion subnet to a private endpoint subnet) instead of allowing `10.10.0.0/16` to any destination.

Wrapper modules should add AKS, Databricks, runner, or application rules through `nsg_rules` or per-subnet `nsg_rules`.

## Platform classification

Resources are tagged:

```text
network_classification = isolated_expansion
isolated_address_space = true
```

Landing zone policy distinguishes these VNets from enterprise-routed spokes:

| Classification | Address space | Connectivity |
| --- | --- | --- |
| `enterprise_routed` | Central IPAM CIDR | vWAN, enterprise routing, hybrid connectivity |
| `isolated_expansion` | Local RFC1918 CIDR | Direct peering only, explicit outbound, no gateway transit |

Name the VNet so it ends with `-isolated-expansion`. Do **not** use a `*-vwan-spoke` name. That pattern is reserved for enterprise-routed spokes and would invite vWAN automation.

Peering names are prefixed with `isolated-expansion-` so `Deny-New-VNet-Peerings` can allow this pattern without opening arbitrary peerings.

This module never offers `enable_vwan`. If a consumer needs a vWAN connection, they are no longer using this architecture.

## Connectivity matrix

| Capability | NAT | Firewall SNAT | None |
| --- | :---: | :---: | :---: |
| Large isolated CIDR | yes | yes | yes |
| Direct peer access | yes | yes | yes |
| Access workload private endpoints | yes | yes | yes |
| Public Internet egress | yes | yes | no |
| Private SNAT | no | yes | no |
| Reach other vWAN spokes / on-prem | no | yes | no |
| Enterprise route to isolated CIDR required | no | no | no |
| Expansion CIDR propagated into vWAN | no | no | no |

## Acceptance tests

NAT mode: expansion can reach the routable VNet, its private endpoints, and the Internet via the NAT public IP. Expansion cannot reach on-prem or other spokes. The isolated prefix must not appear in vWAN routing or ExpressRoute advertisements.

Firewall SNAT mode: local peer traffic keeps the original expansion source IP. Enterprise destinations see the firewall private IP. Return traffic comes through the firewall. The isolated prefix still must not appear in enterprise routing, vWAN, or ExpressRoute.

None mode: expansion can reach the routable VNet, customer Private Endpoints over peering, and local Private Endpoints. Internet and other spokes fail. The isolated prefix must not appear in vWAN routing or ExpressRoute advertisements.

## Invariant

The expansion prefix may be known by the expansion VNet, its directly peered workload VNet, and an optional translation/security boundary. It must never become a required route in the enterprise routing domain.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0, < 2.0.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 2.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_public_ip.nat](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_route.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route.none_blackhole](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_route_table.none](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet_nat_gateway_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.expansion_to_routable](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.routable_to_expansion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azapi_resource_list.central_private_dns_zones](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/resource_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | Isolated RFC1918 address space for the expansion VNet. Must not overlap the routable workload VNet, other directly peered networks, or destinations the expansion workload must reach without SNAT. This prefix must never be advertised into the enterprise routing domain. Defaults to 10.10.0.0/16. | `list(string)` | <pre>[<br/>  "10.10.0.0/16"<br/>]</pre> | no |
| <a name="input_disallowed_address_spaces"></a> [disallowed\_address\_spaces](#input\_disallowed\_address\_spaces) | Known directly connected or otherwise incompatible CIDRs. The module fails if the expansion address space overlaps any of these prefixes. Full enterprise IPAM validation remains outside Terraform. | `list(string)` | `[]` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | DNS configuration for the expansion VNet. Azure-provided DNS is the default. Use custom servers only when those resolvers are reachable from the expansion VNet (in the directly peered workload VNet for NAT mode, or via firewall SNAT for enterprise DNS). | <pre>object({<br/>    mode    = optional(string, "azure")<br/>    servers = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "mode": "azure"<br/>}</pre> | no |
| <a name="input_egress"></a> [egress](#input\_egress) | Outbound connectivity model. Defaults to `none` (private paths only: local VNet, direct peering, and Private Endpoints, with no NAT Gateway or Internet route). Use `nat` when the workload also needs public egress. Use `firewall_snat` when the workload must reach enterprise destinations beyond the peer, with the isolated prefix translated before it enters the enterprise routing domain. | <pre>object({<br/>    mode = optional(string, "none")<br/>    nat = optional(object({<br/>      public_ip_count = optional(number, 1)<br/>      idle_timeout    = optional(number, 10)<br/>      zones           = optional(list(string), ["1"])<br/>      sku_name        = optional(string, "Standard")<br/>      }), {<br/>      public_ip_count = 1<br/>      idle_timeout    = 10<br/>      zones           = ["1"]<br/>      sku_name        = "Standard"<br/>    })<br/>    firewall = optional(object({<br/>      deployment_mode                 = optional(string, "existing")<br/>      firewall_id                     = optional(string)<br/>      firewall_private_ip             = optional(string)<br/>      direct_peer_bypass              = optional(bool, true)<br/>      route_internet_through_firewall = optional(bool, true)<br/>    }))<br/>  })</pre> | <pre>{<br/>  "mode": "none"<br/>}</pre> | no |
| <a name="input_enterprise_routes"></a> [enterprise\_routes](#input\_enterprise\_routes) | Enterprise prefixes that firewall\_snat mode should send to the firewall. Never hard-code these in a wrapper; the caller supplies the prefixes that must be translated before they enter the enterprise routing domain. | `list(string)` | `[]` | no |
| <a name="input_link_private_dns_to_routable_vnet"></a> [link\_private\_dns\_to\_routable\_vnet](#input\_link\_private\_dns\_to\_routable\_vnet) | Also create private DNS zone links on the routable workload VNet. Leave false when those zones are already linked centrally. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | (Required) Azure region to deploy to. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Logical name for the isolated expansion VNet. Used as the Virtual Network name unless virtual\_network\_name is set. In this landing zone, the VNet name should end with `-isolated-expansion` so platform policy can distinguish it from enterprise-routed spokes. | `string` | n/a | yes |
| <a name="input_nsg_default_rules_enabled"></a> [nsg\_default\_rules\_enabled](#input\_nsg\_default\_rules\_enabled) | Create the module's baseline NSG rules (Azure Load Balancer inbound, VNet outbound, deny Internet inbound, Internet outbound in nat/firewall\_snat, Internet deny in none, and enterprise-route outbound in firewall mode). Disable only when supplying a complete custom rule set. | `bool` | `true` | no |
| <a name="input_nsg_rules"></a> [nsg\_rules](#input\_nsg\_rules) | Additional NSG rules applied to every subnet NSG created by this module. Use subnet-level nsg\_rules for workload-specific exceptions. Do not add allow-all rules from the expansion CIDR. | <pre>map(object({<br/>    priority                     = number<br/>    direction                    = string<br/>    access                       = string<br/>    protocol                     = string<br/>    description                  = optional(string)<br/>    source_port_range            = optional(string)<br/>    source_port_ranges           = optional(list(string))<br/>    destination_port_range       = optional(string)<br/>    destination_port_ranges      = optional(list(string))<br/>    source_address_prefix        = optional(string)<br/>    source_address_prefixes      = optional(list(string))<br/>    destination_address_prefix   = optional(string)<br/>    destination_address_prefixes = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | Existing private DNS zone resource IDs to link to the expansion VNet. Central zones should be reused rather than duplicated. Combined with any zones discovered from private\_dns\_zone\_resource\_group\_id. The identity applying this module must be able to write virtual network links on those zones. | `list(string)` | `[]` | no |
| <a name="input_private_dns_zone_resource_group_id"></a> [private\_dns\_zone\_resource\_group\_id](#input\_private\_dns\_zone\_resource\_group\_id) | Resource ID of the central private DNS resource group. When set, every Private DNS zone in that group is linked to the expansion VNet. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Required) Name of the existing resource group that will contain the expansion VNet and its supporting resources. | `string` | n/a | yes |
| <a name="input_routable_vnet"></a> [routable\_vnet](#input\_routable\_vnet) | The existing enterprise-routed workload VNet that this expansion VNet will be directly peered to. This is the only intended private path out of the isolated address space besides an optional firewall SNAT boundary. | <pre>object({<br/>    id                  = string<br/>    name                = string<br/>    resource_group_name = string<br/>    address_space       = optional(list(string), [])<br/>  })</pre> | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Optional subnet map for the expansion VNet. Leave empty when the caller creates workload subnets separately. Wrapper modules should add service-specific delegation, endpoints, and NSG rules here rather than changing the core pattern. | <pre>map(object({<br/>    address_prefix                                = string<br/>    name                                          = optional(string)<br/>    nsg_name                                      = optional(string)<br/>    create_nsg                                    = optional(bool, true)<br/>    nsg_id                                        = optional(string)<br/>    service_endpoints                             = optional(list(string), [])<br/>    private_endpoint_network_policies             = optional(string, "Enabled")<br/>    private_link_service_network_policies_enabled = optional(bool, true)<br/>    default_outbound_access_enabled               = optional(bool, false)<br/>    associate_nat_gateway                         = optional(bool, true)<br/>    associate_route_table                         = optional(bool, true)<br/>    delegation = optional(object({<br/>      name         = optional(string)<br/>      service_name = string<br/>      actions      = optional(list(string), ["Microsoft.Network/virtualNetworks/subnets/join/action"])<br/>    }))<br/>    nsg_rules = optional(map(object({<br/>      priority                     = number<br/>      direction                    = string<br/>      access                       = string<br/>      protocol                     = string<br/>      description                  = optional(string)<br/>      source_port_range            = optional(string)<br/>      source_port_ranges           = optional(list(string))<br/>      destination_port_range       = optional(string)<br/>      destination_port_ranges      = optional(list(string))<br/>      source_address_prefix        = optional(string)<br/>      source_address_prefixes      = optional(list(string))<br/>      destination_address_prefix   = optional(string)<br/>      destination_address_prefixes = optional(list(string))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Additional tags to merge with the isolated\_expansion classification tags. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Override the Azure Virtual Network name. Defaults to `name`. Prefer a name ending in `-isolated-expansion`. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_space"></a> [address\_space](#output\_address\_space) | Address space assigned to the isolated expansion Virtual Network. |
| <a name="output_egress_mode"></a> [egress\_mode](#output\_egress\_mode) | Configured egress mode: nat, firewall\_snat, or none. |
| <a name="output_firewall_private_ip"></a> [firewall\_private\_ip](#output\_firewall\_private\_ip) | Firewall private IP used as the SNAT/routing boundary when egress.mode is firewall\_snat; otherwise null. |
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | NAT Gateway resource ID when egress.mode is nat; otherwise null. |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | Public IP addresses used by the NAT Gateway when egress.mode is nat; otherwise null. |
| <a name="output_network_classification"></a> [network\_classification](#output\_network\_classification) | Platform classification for this VNet. Isolated expansion VNets must not receive enterprise-routed spoke automation such as vWAN connections. |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | Map of subnet keys to NSG resource IDs created by this module. |
| <a name="output_peering_ids"></a> [peering\_ids](#output\_peering\_ids) | Resource IDs for both sides of the expansion-to-routable peering. |
| <a name="output_private_dns_link_ids"></a> [private\_dns\_link\_ids](#output\_private\_dns\_link\_ids) | Map of private DNS virtual network link keys to resource IDs. |
| <a name="output_required_firewall_routes"></a> [required\_firewall\_routes](#output\_required\_firewall\_routes) | Routes a higher-level networking deployment should honour on the firewall path. Null unless egress.mode is firewall\_snat. |
| <a name="output_required_firewall_rules"></a> [required\_firewall\_rules](#output\_required\_firewall\_rules) | Suggested firewall allow sources and destinations for isolated expansion traffic. Null unless egress.mode is firewall\_snat. |
| <a name="output_required_private_snat"></a> [required\_private\_snat](#output\_required\_private\_snat) | Private SNAT contract: isolated source prefixes that must be translated to the firewall's enterprise-routable IP before entering the enterprise routing domain. Null unless egress.mode is firewall\_snat. |
| <a name="output_route_table_ids"></a> [route\_table\_ids](#output\_route\_table\_ids) | Map of route table names to IDs created for firewall SNAT or none mode. Empty in NAT mode. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet keys to subnet resource IDs. |
| <a name="output_subnet_prefixes"></a> [subnet\_prefixes](#output\_subnet\_prefixes) | Map of subnet keys to subnet address prefixes. |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | Resource ID of the isolated expansion Virtual Network. |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | Name of the isolated expansion Virtual Network. |
<!-- END_TF_DOCS -->
