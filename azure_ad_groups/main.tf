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

  # Privileged Role IDs:
  # 8e3af657a8ff443ca75c2fe8c4bcb635 = Owner
  # b24988ac6180420aab8820f7382dd24c = Contributor
  # 18d7d88dd35e4fb5a5c37773c20a72d9 = User Access Administrator
  # f58310d9a9f6439a9e8df62e7b41a168 = Role Based Access Control Administrator
  privileged_role_ids = concat(var.additional_restricted_role_ids, [
    "8e3af657a8ff443ca75c2fe8c4bcb635",
    "b24988ac618042a0ab8820f7382dd24c",
    "18d7d88dd35e4fb5a5c37773c20a72d9",
    "f58310d9a9f6439a9e8df62e7b41a168"]
  )

  # Collect all member UPNs from all groups, plus admin_email if provided
  all_members = distinct(compact(concat(
    flatten([for _, group in local.groups : group.members]),
    var.admin_email != "" && var.admin_email != null ? [var.admin_email] : []
  )))

  # Build a map of member UPN -> object_id for users that were actually found
  # Normalize UPNs to lowercase for case-insensitive matching (Azure AD UPNs are case-insensitive)
  # The data source returns matching arrays, so zipmap should always work when there are results
  member_id_by_upn = length(data.azuread_users.members.user_principal_names) > 0 ? zipmap(
    [for upn in data.azuread_users.members.user_principal_names : lower(upn)],
    data.azuread_users.members.object_ids
  ) : {}

  # Build raw list of all group-member pairs
  raw_group_members = flatten([
    for group_key, group in local.groups : [
      for member in toset(group.members) : {
        group_key = group_key
        member    = member
        key       = "${group_key}-${member}"
      }
    ]
  ])

  # Only keep entries where we actually found the user
  # Normalize member UPN to lowercase for case-insensitive comparison
  # This ensures all keys that should exist are present in the for_each map
  existing_group_members = {
    for item in local.raw_group_members :
    item.key => {
      group_key        = item.group_key
      member           = item.member
      member_object_id = local.member_id_by_upn[lower(item.member)]
    }
    if contains(keys(local.member_id_by_upn), lower(item.member))
  }

  # Terraform-defined owners: admin_email + Terraform execution identity
  # Used only on initial group creation
  terraform_owner_ids = compact([
    try(local.member_id_by_upn[lower(var.admin_email)], null),
    data.azuread_client_config.current.object_id
  ])
}

# Get the current client configuration
data "azuread_client_config" "current" {}

# Get user objects - using plural data source with ignore_missing to handle deleted users
# This includes both group members and admin_email
data "azuread_users" "members" {
  ignore_missing       = true
  user_principal_names = length(local.all_members) > 0 ? local.all_members : []
}

# Create the groups
# lifecycle.ignore_changes on owners prevents Terraform from overwriting owners
# added outside Terraform (e.g. Technical Leads, managed identities in the portal).
# Admin email changes are handled by the null_resource.admin_owner below.
resource "azuread_group" "groups" {
  for_each         = local.groups
  display_name     = each.value.name
  security_enabled = true
  description      = each.value.description
  owners           = local.terraform_owner_ids

  lifecycle {
    ignore_changes = [owners]
  }
}

# Manage admin_email owner lifecycle across all groups.
# When admin_email changes:
#   1. DESTROY provisioner fires with OLD admin_email from state -> removes old admin as owner
#   2. Resource is recreated with new triggers
#   3. CREATE provisioner fires with NEW admin_email -> adds new admin as owner
# Portal-added owners are never touched (ignore_changes on azuread_group.owners).
resource "null_resource" "admin_owner" {
  for_each = local.groups

  triggers = {
    admin_email = var.admin_email
    group_name  = each.value.name
  }

  # When admin_email changes, this fires FIRST with the OLD values from state
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      OLD_ADMIN_ID=$(az ad user show --id "${self.triggers.admin_email}" --query id -o tsv 2>/dev/null || true)
      if [ -n "$OLD_ADMIN_ID" ] && [ "$OLD_ADMIN_ID" != "None" ]; then
        GROUP_ID=$(az ad group list --display-name "${self.triggers.group_name}" --query "[0].id" -o tsv 2>/dev/null || true)
        if [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "None" ]; then
          az ad group owner remove --group "$GROUP_ID" --owner-id "$OLD_ADMIN_ID" 2>/dev/null || echo "Could not remove old admin (may already be gone)"
        fi
      fi
    EOT
  }

  # Then this fires with the NEW admin_email
  provisioner "local-exec" {
    command = <<-EOT
      NEW_ADMIN_ID=$(az ad user show --id "${self.triggers.admin_email}" --query id -o tsv 2>/dev/null || true)
      if [ -n "$NEW_ADMIN_ID" ] && [ "$NEW_ADMIN_ID" != "None" ]; then
        GROUP_ID=$(az ad group list --display-name "${self.triggers.group_name}" --query "[0].id" -o tsv 2>/dev/null || true)
        if [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "None" ]; then
          az ad group owner add --group "$GROUP_ID" --owner-id "$NEW_ADMIN_ID" 2>/dev/null || echo "Could not add new admin (may already be owner)"
        fi
      fi
    EOT
  }

  depends_on = [azuread_group.groups]
}

# Add users to groups (only for users that actually exist)
resource "azuread_group_member" "group_members" {
  for_each = local.existing_group_members

  group_object_id  = azuread_group.groups[each.value.group_key].id
  member_object_id = each.value.member_object_id
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
  @Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {${join(",", local.privileged_role_ids)}}
 )
)
AND
(
 (
  !(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})
 )
 OR
 (
  @Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {${join(",", local.privileged_role_ids)}}
 )
)
EOT
  ) : null
}
