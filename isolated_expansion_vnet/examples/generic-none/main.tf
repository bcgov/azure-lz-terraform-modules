module "compute_expansion" {
  source = "../.."

  name                = "compute-isolated-expansion"
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

    private_endpoints = {
      address_prefix = "10.10.16.0/26"
    }
  }

  egress = {
    mode = "none"
  }

  spoke_dns_resolver = {
    enabled                 = true
    inbound_address_prefix  = var.spoke_dns_inbound_address_prefix
    outbound_address_prefix = var.spoke_dns_outbound_address_prefix
    forward_to              = var.spoke_dns_forward_to
  }
}
