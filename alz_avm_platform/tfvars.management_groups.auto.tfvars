parent_resource_id = "BCGOV-MGD-LZ" # NOTE: This is our team's "tenant root" management group that all other management groups will be created under.
architecture_name  = "avm_alz_custom"

# policy_assignments_to_modify = {
#   BCGov-Managed-LZ-AVM = { # Management Group ID
#     policy_assignments = {
#       # TESTING: [Preview]: Deploy Microsoft Defender for Endpoint agent (Initiative)
#       deploy-mdendpoints = { # Policy Assignment Name
#         parameters = {
#           effect = jsonencode({ value = "AuditIfNotExists" })
#         }
#       }
#     }
#   }
# }
