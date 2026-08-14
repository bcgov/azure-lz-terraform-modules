# Example of how an AKS network wrapper would call the core module.
# AKS-specific cluster resources belong in a separate wrapper, not here.

module "aks_expansion" {
  source = "../.."

  name                = "aks-isolated-expansion"
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = ["10.200.0.0/16"]

  routable_vnet = {
    id                  = var.routable_vnet_id
    name                = var.routable_vnet_name
    resource_group_name = var.routable_vnet_resource_group_name
    address_space       = var.routable_vnet_address_space
  }

  subnets = {
    nodes = {
      address_prefix = "10.200.0.0/20"

      delegation = {
        service_name = "Microsoft.ContainerService/managedClusters"
      }
    }

    pods = {
      address_prefix = "10.200.16.0/20"
    }
  }

  egress = {
    mode = "nat"
  }

  private_dns_zone_ids = var.private_dns_zone_ids
}
