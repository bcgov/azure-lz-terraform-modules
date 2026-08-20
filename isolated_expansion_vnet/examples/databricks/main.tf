# Databricks classic compute-plane on an isolated expansion VNet.
# Customer Storage / Key Vault / Event Hub / SQL Private Endpoints stay in the
# routable workload VNet. The databricks_ui_api Private Endpoint belongs in the
# expansion VNet private_endpoints subnet. This module does not create those PEs.
#
# Databricks-owned artifact storage, log storage, platform Event Hubs, and
# metastore endpoints may still require a translated path. Without Unity
# Catalog, treat none as a prototype only; switch egress.mode to nat if
# HMS or artifact pull fails. Prefer dns_forwarding_ruleset_id over a
# spoke DNS resolver.

module "databricks_expansion" {
  source = "../.."

  name                = "databricks-isolated-expansion"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["10.10.0.0/16"]

  routable_vnet = {
    id                  = var.routable_vnet_id
    name                = var.routable_vnet_name
    resource_group_name = var.routable_vnet_resource_group_name
    address_space       = var.routable_vnet_address_space
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
      address_prefix                    = "10.10.8.0/26"
      private_endpoint_network_policies = "Enabled"
    }
  }

  egress = {
    mode = "none"
  }

  dns_forwarding_ruleset_id = var.dns_forwarding_ruleset_id
  spoke_dns_resolver        = var.spoke_dns_resolver
}
