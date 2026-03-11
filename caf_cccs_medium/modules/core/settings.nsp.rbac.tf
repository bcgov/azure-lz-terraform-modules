locals {
  deploy_nsp_assignment_scope = "/providers/Microsoft.Management/managementGroups/${var.root_id}-landing-zones"
  deploy_nsp_rg_scope         = "/subscriptions/${var.nsp_subscription_id}/resourceGroups/${var.nsp_resource_group_name}"
}

data "azurerm_policy_assignment" "deploy_nsp_association" {
  count = var.nsp_subscription_id != "" && var.nsp_resource_group_name != "" ? 1 : 0

  name  = "Deploy-NSP-Association"
  scope = local.deploy_nsp_assignment_scope

  depends_on = [module.alz]
}

resource "azurerm_role_assignment" "deploy_nsp_association_contributor_on_nsp_rg" {
  count = var.nsp_subscription_id != "" && var.nsp_resource_group_name != "" ? 1 : 0

  scope                = local.deploy_nsp_rg_scope
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_policy_assignment.deploy_nsp_association[0].identity[0].principal_id

  skip_service_principal_aad_check = true
}
