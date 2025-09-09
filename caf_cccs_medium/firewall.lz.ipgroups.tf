module "lz_firewall_ipgroups" {
  source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_ip_group?ref=v1.0.23"
  # source = "../azure_ip_group"

  subscription_id_connectivity = var.subscription_id_connectivity

  resource_group_name = var.ip_group_resource_group_name
  location            = var.primary_location
  ip_group            = var.ip_group
}
