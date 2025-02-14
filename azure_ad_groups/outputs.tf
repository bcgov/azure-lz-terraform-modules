output "groups" {
  description = "Map of created Azure AD groups"
  value = {
    for k, v in azuread_group.groups : k => {
      id           = v.id
      object_id    = v.object_id
      display_name = v.display_name
    }
  }
} 
