#------------------------------------------------------------------------------
# IPAM - IP Address Management
#
# Allocates IP address space from Azure Network Manager IPAM Pool
# for the MCCS Observability Platform subnets.
#
# Allocation: /24 (256 addresses) split into three /26 subnets:
# - Container instances subnet: /26 (64 addresses)
# - PostgreSQL subnet: /26 (64 addresses)
# - Private endpoints subnet: /26 (64 addresses)
#------------------------------------------------------------------------------

resource "azurerm_network_manager_ipam_pool_static_cidr" "mccs_observability" {
  count = var.use_ipam ? 1 : 0

  name                               = "mccs-observability-${var.environment}"
  ipam_pool_id                       = var.network_manager_ipam_pool_id
  number_of_ip_addresses_to_allocate = 256 # /24 for three /26 subnets

  lifecycle {
    precondition {
      condition     = var.use_ipam == false || var.network_manager_ipam_pool_id != null
      error_message = "network_manager_ipam_pool_id is required when use_ipam is true."
    }
  }
}

#------------------------------------------------------------------------------
# Validation Check: Ensure proper configuration
#------------------------------------------------------------------------------

check "ipam_configuration" {
  assert {
    condition = (
      (var.use_ipam == true && var.network_manager_ipam_pool_id != null) ||
      (var.use_ipam == false && var.vnet_address_space != null)
    )
    error_message = "When use_ipam is true, network_manager_ipam_pool_id must be provided. When use_ipam is false, vnet_address_space must be provided."
  }
}
