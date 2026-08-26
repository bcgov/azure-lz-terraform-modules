module "alz" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "~> 0.21.0"

  # Required Configuration
  architecture_name  = var.architecture_name
  location           = var.location
  parent_resource_id = var.parent_resource_id

  subscription_placement_destroy_behavior = var.subscription_placement_destroy_behavior
}
