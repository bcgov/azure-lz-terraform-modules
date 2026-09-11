locals {
  platform_subscriptions = {
    "connectivity" = {
      subscription_display_name                         = "bcgov-mgd-lz-avm-connectivity"
      subscription_id                                   = "6b779108-96a1-48cd-8c7a-804c5a924d44"
      subscription_management_group_association_enabled = true
      subscription_management_group_id                  = "bcgov-managed-lz-avm-connectivity"
      subscription_update_existing                      = true
      subscription_workload                             = "Production"
    },
    "identity" = {
      subscription_display_name                         = "bcgov-mgd-lz-avm-identity"
      subscription_id                                   = "561b8413-cd9f-4b91-8745-c5937d8b3a61"
      subscription_management_group_association_enabled = true
      subscription_management_group_id                  = "bcgov-managed-lz-avm-identity"
      subscription_update_existing                      = true
      subscription_workload                             = "Production"
    },
    "management" = {
      subscription_display_name                         = "bcgov-mgd-lz-avm-management"
      subscription_id                                   = "7eaf8022-ff10-43bd-851b-54c11c0fb515"
      subscription_management_group_association_enabled = true
      subscription_management_group_id                  = "bcgov-managed-lz-avm-management"
      subscription_update_existing                      = true
      subscription_workload                             = "Production"
    },
    "security" = {
      subscription_display_name                         = "bcgov-mgd-lz-avm-security"
      subscription_id                                   = "af6fee0c-9967-44d0-86f9-4bd603ffa174"
      subscription_management_group_association_enabled = true
      subscription_management_group_id                  = "bcgov-managed-lz-avm-security"
      subscription_update_existing                      = true
      subscription_workload                             = "Production"
    }
  }
}