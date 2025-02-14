locals {
  groups = {
    owners = {
      name        = "DO_PuC_Azure_${title(var.environment)}_${var.license_plate}_Owners"
      description = "Owners group for ${var.project_name} project set in Azure ${title(var.environment)} LZ"
      role        = "Owner"
      members     = var.owners
    }
    contributors = {
      name        = "DO_PuC_Azure_${title(var.environment)}_${var.license_plate}_Contributors"
      description = "Contributors group for ${var.project_name} project set in Azure ${title(var.environment)} LZ"
      role        = "Contributor"
      members     = var.contributors
    }
    readers = {
      name        = "DO_PuC_Azure_${title(var.environment)}_${var.license_plate}_Readers"
      description = "Readers group for ${var.project_name} project set in Azure ${title(var.environment)} LZ"
      role        = "Reader"
      members     = var.readers
    }
  }
}

# Get the current client configuration
data "azuread_client_config" "current" {}

# Get user objects
data "azuread_user" "users" {
  for_each            = toset(flatten([for group in local.groups : group.members]))
  user_principal_name = each.key
}

# Create the groups
resource "azuread_group" "groups" {
  for_each         = local.groups
  display_name     = each.value.name
  security_enabled = true
  description      = each.value.description
  owners = compact([
    try(data.azuread_user.users[var.admin_email].object_id, null),
    data.azuread_client_config.current.object_id
  ])
}

# Add users to groups
resource "azuread_group_member" "group_members" {
  for_each = {
    for item in flatten([
      for group_key, group in local.groups : [
        for member in group.members : {
          group_key = group_key
          member    = member
        }
      ]
    ]) : "${item.group_key}-${item.member}" => item
  }

  group_object_id  = azuread_group.groups[each.value.group_key].id
  member_object_id = data.azuread_user.users[each.value.member].object_id
}

# Assign roles to groups
resource "azurerm_role_assignment" "group_roles" {
  for_each             = local.groups
  scope                = var.scope
  role_definition_name = each.value.role
  principal_id         = azuread_group.groups[each.key].object_id
  description          = "${var.license_plate} ${each.value.role} Group Assignment"

  condition_version = each.value.role == "Owner" ? "2.0" : null
  condition = each.value.role == "Owner" ? (<<EOT
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})
 )
 OR
 (
  @Request[Microsoft.Authorization/roleAssignments:PrincipalType] StringEquals 'ServicePrincipal'
 )
)
AND
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
 )
 OR
 (
  @Resource[Microsoft.Authorization/roleAssignments:PrincipalType] StringEquals 'ServicePrincipal'
 )
)
EOT
  ) : null
}
