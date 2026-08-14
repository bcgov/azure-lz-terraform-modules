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

  dns_forwarding_ruleset_id = var.dns_forwarding_ruleset_id
}
