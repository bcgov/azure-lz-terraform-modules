# variable "subscription_placement" {
#   type = map(object({
#     subscription_id       = string
#     management_group_name = string
#   }))

#   description = "A map of subscription placements for the architecture. Each key is a workload name, and the value is an object containing the subscription ID and management group name."
# }