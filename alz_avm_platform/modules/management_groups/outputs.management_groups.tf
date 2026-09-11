# output "alz" {
#   value      = module.alz
# }

output "management_group_resource_ids" {
  description = "A map of management group names to their resource ids."
  value       = module.alz.management_group_resource_ids
}

# output "policy_assignment_identity_ids" {
#   description = "A map of policy assignment names to their identity ids."
#   value       = module.alz.policy_assignment_identity_ids
# }

# output "policy_assignment_resource_ids" {
#   description = "A map of policy assignment names to their resource ids."
#   value       = module.alz.policy_assignment_resource_ids
# }

# output "policy_definition_resource_ids" {
#   description = "A map of policy definition names to their resource ids."
#   value       = module.alz.policy_definition_resource_ids
# }

# output "policy_role_assignment_resource_ids" {
#   description = "A map of policy role assignments to their resource ids."
#   value       = module.alz.policy_role_assignment_resource_ids
# }

# output "policy_set_definition_resource_ids" {
#   description = "A map of policy set definition names to their resource ids."
#   value       = module.alz.policy_set_definition_resource_ids
# }

# output "role_definition_resource_ids" {
#   description = "A map of role definition names to their resource ids."
#   value       = module.alz.role_definition_resource_ids
# }
