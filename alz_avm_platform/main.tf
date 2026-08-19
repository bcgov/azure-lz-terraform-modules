module "alz" {
  source  = "Azure/avm-ptn-alz/azurerm"
  version = "0.21.0"

  architecture_name  = var.architecture_name
  location           = var.location
  parent_resource_id = local.parent_resource_id
}
