module "ftk_supporting_resources" {
  # source = "git::https://github.com/bcgov/azure-lz-terraform-modules.git//azure_private_dns/virtual_network?ref=v0.0.42"
  # source = "../../azure-lz-terraform-modules/azure_private_dns/virtual_network" # For local testing only
  source = "../supporting_resources" # For local testing only

  IPAM_TOKEN  = var.IPAM_TOKEN # This is used to obtain a CIDR block from an IPAM service
  environment = var.environment

  subscription_id_management              = local.subscription_id_management
}
