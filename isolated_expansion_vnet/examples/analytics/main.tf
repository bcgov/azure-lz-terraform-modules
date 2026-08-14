# Example of how an analytics network wrapper would call the core module.

module "analytics_expansion" {
  source = "../.."

  name                = "analytics-isolated-expansion"
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
    compute = {
      address_prefix = "10.10.0.0/20"
    }

    databricks_public = {
      address_prefix = "10.10.16.0/22"

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
      address_prefix = "10.10.20.0/22"

      delegation = {
        service_name = "Microsoft.Databricks/workspaces"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
        ]
      }
    }
  }

  egress = {
    mode = "nat"
  }

  private_dns_zone_ids = var.private_dns_zone_ids
}
