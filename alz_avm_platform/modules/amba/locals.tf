locals {
  root_management_group_name = yamldecode(file("${path.root}/lib/architecture_definitions/alz_custom.alz_architecture_definition.yaml")).management_groups[0].id
}