module "lz_firewall_ipgroups" {
  source = "../azure_ip_group"

  subscription_id_connectivity = var.subscription_id_connectivity

  resource_group_name = var.ip_group_resource_group_name
  location            = var.location
  ip_group            = var.ip_group
}
