module "management_groups" {
  source  = "./modules/management_groups"

  # Required Configuration
  architecture_name  = var.architecture_name
  location           = var.location

  subscription_placement = var.subscription_placement
}
