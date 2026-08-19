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
  }

  egress = {
    mode = "private_nat"

    private_nat = {
      subnet_address_prefix     = var.private_nat_subnet_address_prefix
      ssh_admin_group_object_id = var.ssh_admin_group_object_id
      ssh_public_key            = var.ssh_public_key
      hub_firewall_dns_servers  = var.hub_firewall_dns_servers
      spoke_route_table_id      = var.spoke_route_table_id
    }
  }

  enterprise_routes = var.enterprise_routes
}
