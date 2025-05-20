locals {
  root_management_group_name = jsondecode(file("${path.root}/lib/custom.alz_architecture_definition.json")).management_groups[0].id
}
