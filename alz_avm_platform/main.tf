module "management_groups" {
  source  = "./modules/management_groups"

  # Required Configuration
  architecture_name  = var.architecture_name
  location           = var.location

  # subscription_placement = var.subscription_placement
}

module "platform_subscriptions" {
  source  = "./modules/platform_subscriptions"

  # Required Configuration
  location               = var.location
  platform_subscriptions = var.platform_subscriptions
}
