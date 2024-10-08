resource "azurerm_role_assignment" "this" {
  scope        = var.role_assignment_scope
  principal_id = var.principal_id

  role_definition_id   = var.role_definition_id
  role_definition_name = var.role_definition_name
}
