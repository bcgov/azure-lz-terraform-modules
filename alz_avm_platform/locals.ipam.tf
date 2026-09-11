locals {
  ipam_pool_resource_group_name = "bcgov-managed-lz-avm-ipam"
  network_manager_name          = "bcgov-managed-lz-avm-ipam-network-manager"
  scope = { # IMPORTANT: FORGE scope is set to Subscription, LIVE scope is set to Management Group
    # management_group_ids = ["/providers/Microsoft.Management/managementGroups/bcgov-managed-lz-avm"]
    subscription_ids = ["/subscriptions/7eaf8022-ff10-43bd-851b-54c11c0fb515"]
  }
  ipam_pool_name             = "bcgov-managed-lz-avm-ipam-pool"
  ipam_pool_display_name     = "BCGov-Managed-LZ-AVM-IPAM-Pool"
  ipam_pool_description      = "BCGov Managed LZ AVM IPAM Pool for managing IP address space in the BCGov Managed Landing Zone"
  ipam_pool_address_prefixes = ["10.41.0.0/16"]
}