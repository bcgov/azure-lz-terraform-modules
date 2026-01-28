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
}

# Get the current client configuration
data "azuread_client_config" "current" {}

# Get user objects - using plural data source with ignore_missing to handle deleted users
# This includes both group members and admin_email
data "azuread_users" "members" {
  ignore_missing       = true
  user_principal_names = length(local.all_members) > 0 ? local.all_members : []
}

locals {
  # Admin email object ID (null if user doesn't exist)
  admin_email_object_id = try(local.member_id_by_upn[lower(var.admin_email)], null)
}

# Check current owners of each group using Azure CLI (inline script)
data "external" "group_owners" {
  for_each = azuread_group.groups

  program = ["bash", "-c", <<-EOF
    group_id=$(jq -r '.group_id')
    owners=$(az ad group owner list --group "$group_id" --query "[].id" -o tsv 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')
    jq -n --arg ids "$${owners:-[]}" '{"owner_ids": $ids}'
EOF
  ]

  query = {
    group_id = each.value.id
  }
}

locals {
  # Parse current owners from external data
  current_owner_ids = {
    for k, v in data.external.group_owners : k => try(jsondecode(v.result["owner_ids"]), [])
  }

  # Groups where admin_email is NOT currently an owner (for drift correction)
  groups_missing_admin = {
    for k in keys(local.groups) : k => azuread_group.groups[k].id
    if local.admin_email_object_id != null && !contains(try(local.current_owner_ids[k], []), local.admin_email_object_id)
  }
}

# Create the groups (Terraform execution identity as owner so creation succeeds; all owners also added via terraform_data for clean remove on destroy)
# lifecycle.ignore_changes on owners prevents Terraform from overwriting owners changed outside Terraform (e.g. in the portal)
resource "azuread_group" "groups" {
  for_each         = local.groups
  display_name     = each.value.name
  security_enabled = true
  description      = each.value.description
  owners           = [data.azuread_client_config.current.object_id]

  lifecycle {
    ignore_changes = [owners]
  }
}

# Manage admin_email lifecycle: handles admin email CHANGES (remove old, add new)
# Triggers only on admin_email_object_id - stable, no churn
resource "terraform_data" "admin_owner" {
  for_each = local.admin_email_object_id != null ? local.groups : {}

  # Only trigger replacement when admin_email changes
  triggers_replace = [
    local.admin_email_object_id
  ]

  input = {
    group_id = azuread_group.groups[each.key].id
    admin_id = local.admin_email_object_id
  }

  # Add admin on create (initial or after admin email change)
  provisioner "local-exec" {
    command = "az ad group owner add --group ${self.input.group_id} --owner-object-id ${self.input.admin_id}"
  }

  # Remove admin on destroy (when admin email changes, removes OLD admin from state)
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      az ad group owner remove --group ${self.input.group_id} --owner-object-id ${self.input.admin_id} || echo "Owner ${self.input.admin_id} could not be removed (may already be gone or user deleted)"
    EOT
  }
}

# Drift correction: re-add admin if removed outside Terraform
# This resource is created when admin is missing, destroyed (no-op) when present
# Fixes drift in a single apply - resource "churns" but Azure state is correct
resource "terraform_data" "ensure_admin_present" {
  for_each = local.groups_missing_admin

  input = {
    group_id = each.value
    admin_id = local.admin_email_object_id
  }

  # Add admin when this resource is created (admin was missing)
  provisioner "local-exec" {
    command = "az ad group owner add --group ${self.input.group_id} --owner-object-id ${self.input.admin_id}"
  }

  # No destroy provisioner - when admin is present, this resource is removed from
  # for_each and destroyed as a no-op (we don't want to remove the admin)
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
