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

  desired_group_names = [for _, group in local.groups : group.name]

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

  existing_group_object_id_by_name = length(data.azuread_groups.existing.display_names) > 0 ? zipmap(
    data.azuread_groups.existing.display_names,
    data.azuread_groups.existing.object_ids
  ) : {}

  existing_groups = {
    for group_key, group in local.groups :
    group_key => {
      object_id = local.existing_group_object_id_by_name[group.name]
    }
    if contains(keys(local.existing_group_object_id_by_name), group.name)
  }

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

# Read any matching pre-existing groups so required owners can be merged with
# current owners without removing owners that were added outside Terraform.
data "azuread_groups" "existing" {
  display_names    = local.desired_group_names
  ignore_missing   = true
  security_enabled = true
}

data "azuread_group" "existing" {
  for_each = local.existing_groups

  object_id = each.value.object_id
}

# Create the groups
# Preserve existing owners while always ensuring the current admin_email and
# Terraform execution identity remain owners of every group.
resource "azuread_group" "groups" {
  for_each         = local.groups
  display_name     = each.value.name
  security_enabled = true
  description      = each.value.description
  owners = distinct(concat(
    try(data.azuread_group.existing[each.key].owners, []),
    local.terraform_owner_ids
  ))
}

# Add users to groups in an add-only manner.
# This avoids failures when a desired membership already exists in Entra ID
# outside Terraform state, and it does not remove members when they are later
# removed from Terraform inputs.
resource "null_resource" "group_members" {
  for_each = local.existing_group_members

  triggers = {
    group_key        = each.value.group_key
    group_name       = local.groups[each.value.group_key].name
    group_object_id  = azuread_group.groups[each.value.group_key].id
    member           = each.value.member
    member_object_id = each.value.member_object_id
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "Ensuring member '${self.triggers.member}' is in group '${self.triggers.group_name}'..."

      IS_MEMBER=$(az ad group member check \
        --group "${self.triggers.group_object_id}" \
        --member-id "${self.triggers.member_object_id}" \
        --query value -o tsv 2>/dev/null || echo "false")

      if [ "$IS_MEMBER" = "true" ]; then
        echo "Member is already in the group, skipping add."
        exit 0
      fi

      if az ad group member add \
        --group "${self.triggers.group_object_id}" \
        --member-id "${self.triggers.member_object_id}"; then
        echo "Successfully added member to group."
      else
        echo "ERROR: Failed to add member to group. Check permissions."
        exit 1
      fi
    EOT
  }

  depends_on = [azuread_group.groups]
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
