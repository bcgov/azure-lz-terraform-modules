module "compute_expansion" {
  source = "../.."

  name                = "compute-isolated-expansion"
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
    compute = {
      address_prefix = "10.200.0.0/20"
    }

    workers = {
      address_prefix = "10.200.16.0/20"
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
